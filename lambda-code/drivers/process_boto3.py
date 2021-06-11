from json import loads

import boto3
from botocore.response import StreamingBody


DISALLOWED_CLIENTS = {'kms', 'secretsmanager'}


def process_row(
    client_name, method_name, results_path=None, region='us-west-2', **kwargs
):
    if client_name in DISALLOWED_CLIENTS:
        return
    method = getattr(boto3.client(client_name, region), method_name)
    result = method(**kwargs)
    if (
        results_path
        and result.get('ContentType') == 'application/json'
        and isinstance(result.get('Body'), StreamingBody)
    ):
        result = pick(results_path, loads(result.get('Body')).read())
    return result
