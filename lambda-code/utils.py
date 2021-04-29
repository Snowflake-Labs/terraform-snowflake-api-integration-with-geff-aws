import json
import re
import time
from codecs import encode
from json import dumps
from typing import Any, Dict, Optional, Text

import boto3

REGION_NAME = 'us-west-2'


def pick(path: str, d: dict):
    # path e.g. "a.b.c"
    retval: Optional[Any] = d
    for p in path.split('.'):
        if p and retval:
            retval = retval.get(p)
    return retval


# from https://requests.readthedocs.io/en/master/_modules/requests/utils/
def parse_header_links(value):
    """Return a list of parsed link headers proxies.

    i.e. Link: <http:/.../front.jpeg>; rel=front; type="image/jpeg",<http://.../back.jpeg>; rel=back;type="image/jpeg"

    :rtype: list
    """
    links = []
    replace_chars = ' \'"'

    value = value.strip(replace_chars)
    if not value:
        return links

    for val in re.split(', *<', value):
        try:
            url, params = val.split(';', 1)
        except ValueError:
            url, params = val, ''

        link = {'url': url.strip('<> \'"')}

        for param in params.split(';'):
            try:
                key, value = param.split('=')
            except ValueError:
                break

            link[key.strip(replace_chars)] = value.strip(replace_chars)

        links.append(link)

    return links


def zip(s, chunk_size=1_000_000):
    '''zip in pieces, as it is tough to inflate large chunks in Snowflake per UDF mem limits'''
    def do_zip(s): return encode(
        encode(s.encode(), encoding='zlib'), 'base64').decode()
    if len(s) > chunk_size:
        return [do_zip(s[:chunk_size])] + zip(s[chunk_size:], chunk_size)
    return [do_zip(s)]


def format(s, ps):
    """format string s with params ps, preserving type of singular references

    >>> format('{0}', [{'a': 'b'}])
    {'a': 'b'}

    >>> format('{"z": [{0}]}', [{'a': 'b'}])
    """

    def replace_refs(s, ps):
        for i, p in enumerate(ps):
            old = '{' + str(i) + '}'
            new = dumps(p) if isinstance(p, (list, dict)) else str(p)
            s = s.replace(old, new)
        return s

    m = re.match('{(\d+)}', s)
    return ps[int(m.group(1))] if m else replace_refs(s, ps)


def create_response(code, msg):
    return {'statusCode': code, 'body': msg}


def invoke_process_lambda(event, lambda_name: str) -> Dict[Text, Any]:
    # Create payload to be sent to lambda
    invoke_payload = json.dumps(event)

    # Invoke processing lambda asynchronously by using InvocationType='Event'.
    # This allows the processing to continue while the POST handler returns HTTP 202.
    lambda_client = boto3.client(
        'lambda',
        region_name=REGION_NAME,
    )
    lambda_response = lambda_client.invoke(
        FunctionName=lambda_name, InvocationType='Event', Payload=invoke_payload
    )
    # returns 202 on success if InvocationType = 'Event'
    return lambda_response
