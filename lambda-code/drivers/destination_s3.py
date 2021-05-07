import json
from random import sample
from typing import Any, AnyStr, Dict, Generator, List, Optional, Text, Tuple
from urllib.parse import urlparse

import boto3
from botocore.exceptions import ClientError

SAMPLE_SIZE: int = 10
MAX_JSON_FILE_SIZE: int = 15 * 1024 * 1024 * 1024
AWS_REGION = 'ap-south-1'  # Placeholder while in dev TODO: change as variable/header
S3_CLIENT = boto3.client('s3', region_name=AWS_REGION)
MANIFEST_FILENAME = 'MANIFEST.json'


def parse_destination_uri(destination: Text) -> Tuple[Text, Text]:
    """Parses the URL into bucket and prefix

    Args:
        destination (Text): [description]

    Returns:
        Tuple[Text, Text]: [description]
    """
    print(f'destination from header is {destination}')
    parsed_url = urlparse(destination)
    bucket = parsed_url.netloc
    print(f'Using path = {parsed_url.path} to parse prefix.')
    prefix = parsed_url.path.split('/', 2)[1]
    print(f'Parsed bucket = {bucket}, prefix = {prefix}.')
    return bucket, prefix


def estimated_record_size(records: List[Dict[Text, Any]]) -> float:
    """
    A helper utility to get a rough (really rough) estimate of
    the size of a single record in a list of dictionary objects.
    We assume it is json serializable for writing to a file.

    Args:
        records (List[Dict[Text, Any]]): [description]

    Returns:
        float: [description]
    """
    sample_list = sample(records, SAMPLE_SIZE)
    sample_json_str = json.dumps({'data': sample_list})
    return len(sample_json_str) / SAMPLE_SIZE


def chunker(records: List[Any], chunk_size: int) -> Generator[List[Any], None, None]:
    """
    Use to paginate a list of objects.
    >>> a = [1,2,3,4,5]
    >>> for chunk in chunker(a, 2):
    ...     print(chunk)
    ...
    [1, 2]
    [3, 4]
    [5]

    Args:
        records (List[Any]): List of records we want to paginate
        chunk_size (int): Represents the size of chunk we want to return

    Yields:
        List[Any]: Returns a list of objects chunk size at a time
    """
    for pos in range(0, len(records), chunk_size):
        yield records[pos : pos + chunk_size]


def write_to_s3(bucket: Text, filename: Text, content: AnyStr) -> Dict[Text, Any]:
    return S3_CLIENT.put_object(
        Bucket=bucket,
        Body=content,
        Key=filename,
    )


def initialize(destination: Text, batch_id: Text):
    bucket, prefix = parse_destination_uri(destination)
    content = ''  # We use empty body for creating a folder
    prefixed_folder = f'{prefix}/{batch_id}/'
    return write_to_s3(bucket, prefixed_folder, content)


def write(
    destination: Text,
    batch_id: Text,
    datum: Dict,
    row_index: int,
) -> Dict[str, Any]:
    bucket, prefix = parse_destination_uri(destination)
    encoded_datum = json.dumps(datum)
    prefixed_filename = f'{prefix}/{batch_id}/row-{row_index}.data.json'
    s3_uri = f's3://{bucket}/{prefixed_filename}'

    return {
        'response': write_to_s3(
            bucket,
            prefixed_filename,
            encoded_datum,
        ),
        'uri': s3_uri,
    }


def finalize(
    destination: Text,
    batch_id: Text,
    datum: Dict,
) -> Dict[str, Any]:
    bucket, prefix = parse_destination_uri(destination)
    encoded_datum = json.dumps(datum)
    prefixed_filename = f'{prefix}/{batch_id}/{MANIFEST_FILENAME}'
    s3_uri = f's3://{bucket}/{prefixed_filename}'

    return {
        'response': write_to_s3(
            bucket,
            prefixed_filename,
            encoded_datum,
        ),
        'uri': s3_uri,
    }


def check_status(destination: Text, batch_id: Text) -> Optional[List[Any]]:
    bucket, prefix = parse_destination_uri(destination)
    try:
        response_obj = S3_CLIENT.get_object(
            Bucket=bucket,
            Key=f'{prefix}/{batch_id}/{MANIFEST_FILENAME}',
        )
        content = response_obj['Body']
        json_object = json.loads(content.read())
    except ClientError as ce:
        if ce.response['Error']['Code'] == 'NoSuchKey':
            print('No manifest file found returning None.')
            return None
    else:
        print(f'Manifest file found returning contents. {json_object}')
        return json_object

    return None
