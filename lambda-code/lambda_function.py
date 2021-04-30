import os.path
import sys
from importlib import import_module
from json import dumps, loads
from typing import Any, Dict, Optional, Text
from urllib.parse import urlparse

from utils import create_response, format, invoke_process_lambda, zip

# pip install --target ./site-packages -r requirements.txt
dir_path = os.path.dirname(os.path.realpath(__file__))
sys.path.append(os.path.join(dir_path, 'site-packages'))


def async_flow_poll(event: Any, destination: str, context: Any) -> Dict[str, Any]:
    """
    Repeatedly checks on the status of the batch, and returns the result after the
    processing has been completed

    Args:
        event (Any):
        destination (str):
        context (Any):

    Returns:
        Dict[str, Any]:
    """
    batch_id = event['headers']['sf-external-function-query-batch-id']
    write_driver = import_module(
        f'drivers.destination_{urlparse(destination).scheme}')
    # Ignoring style due to dynamic import
    status_body = write_driver.check_status(
        destination, batch_id)  # type: ignore

    if status_body:
        return {'statusCode': 200, 'body': status_body}
    else:
        return {'statusCode': 202}


def async_flow_init(event: Any, context: Any) -> Dict[Text, Any]:
    """
    Handles the async part of the request flows.

    Args:
        event (Any):
        context (Any): Has the function context. Defaults to None.

    Returns:
        Dict[Text, Any]: Represents the response state and data.
    """
    headers = event['headers']
    batch_id = headers['sf-external-function-query-batch-id']
    destination = headers['sf-custom-destination']
    headers.pop('sf-custom-destination')
    headers['write-uri'] = destination
    lambda_name = context.function_name

    destination_driver = import_module(
        f'drivers.destination_{urlparse(destination).scheme}'
    )
    # Ignoring style due to dynamic import
    destination_driver.init(destination, batch_id)  # type: ignore

    lambda_response = invoke_process_lambda(event, lambda_name)
    if lambda_response['StatusCode'] != 202:
        return create_response(400, 'Error invoking child lambda.')
    else:
        return {'statusCode': 202}


def lambda_handler(event, context):
    destination = event['headers'].get('sf-custom-destination')
    method = event.get('httpMethod', 'GET')

    # The first request is always a POST unless SF is polling for status.
    if destination:  # POST + dest header == async flow
        return async_flow_init(event, context)
    elif method == 'GET':  # First request being GET == request is a snowflake poll
        return async_flow_poll(event, context)
    elif method == 'POST':  # POST + no dest header == Regular request for data
        return sync_flow(event, context)


def sync_flow(event: Any, context: Any = None) -> Dict[Text, Any]:
    """
    Handles the synchronous part of the sync + async flows.

    Args:
        event (Any):
        context (Any): Has the function context. Defaults to None.

    Returns:
        Dict[Text, Any]: Represents the response state and data.
    """
    headers = event['headers']
    response_encoding = headers.pop('sf-custom-response-encoding', None)
    write_uri = headers.get('write-uri')
    req_body = loads(event['body'])
    destination_driver = import_module(
        f'drivers.destination_{urlparse(write_uri).scheme}'
    )
    batch_id = headers['sf-external-function-query-batch-id']
    res_data = []

    for row_number, *args in req_body['data']:
        row_result = []
        process_row_params = {
            k.replace('sf-custom-', '').replace('-', '_'): format(v, args)
            for k, v in headers.items()
            if k.startswith('sf-custom-')
        }

        try:
            driver, *path = event['path'].lstrip('/').split('/')
            driver = driver.replace('-', '_')
            process_row = import_module(
                f'drivers.process_{driver}', package=None
            ).process_row  # type: ignore
            row_result = process_row(*path, **process_row_params)
            if write_uri:
                # Write s3 data and return confirmation
                # Ignoring style due to dynamic import
                row_result = destination_driver.write(   # type: ignore
                    write_uri, batch_id, row_number, row_result
                )

        except Exception as e:
            row_result = [{'error': repr(e)}]

        res_data.append(
            [
                row_number,
                zip(dumps(row_result)) if response_encoding == 'gzip' else row_result,
            ]
        )
    data_dumps = dumps({'data': res_data})

    if len(data_dumps) > 6_000_000:
        data_dumps = dumps(
            {
                'data': [
                    [
                        rn,
                        {
                            'error': (
                                f'Response size ({len(data_dumps)} bytes) will likely'
                                'exceeded maximum allowed payload size (6291556 bytes).'
                            )
                        },
                    ]
                    for rn, *args in req_body['data']
                ]
            }
        )

    return {'statusCode': 200, 'body': data_dumps}
