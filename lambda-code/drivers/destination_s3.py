import json
from random import sample
from typing import Any, Dict, List, Text, Generator
from urllib.parse import urlparse

import boto3

SAMPLE_SIZE: int = 10
MAX_JSON_FILE_SIZE: int = 15 * 1024 * 1024 * 1024
S3_CLIENT = boto3.client('s3')


def estimated_record_size(records: List[Dict[Text, Any]]) -> float:
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
        yield records[pos: pos + chunk_size]


def init(batch_id: Text, destination: Text):
    parsed_url = urlparse(destination)
    bucket = parsed_url.netloc
    prefix = parsed_url.path.split('/', 2)[1]
    return S3_CLIENT.put_object(Bucket=bucket, Body='', Key=f'{prefix}/{batch_id}/')


def write(
    batch_id: Text,
    bucket: Text,
    key: Text,
    row_index: int,
    datum: Dict,
) -> Dict[str, Any]:
    encoded_datum = json.dumps(datum)
    return {
        'response': S3_CLIENT.put_object(
            Bucket=bucket,
            Body=encoded_datum,
            Key=f'{key}/{batch_id}/row-{row_index}.data.json',
        ),
        'filepath': f's3://{bucket}/{key}/{batch_id}/row-{row_index}.data.json',
    }
