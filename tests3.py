import boto3
from botocore.exceptions import ClientError
import json

bucket = 'prasanthk-test-bucket'
prefix = 'prefix-1'
batch_id = 'batch-1'

s3_client = boto3.client(
    's3',
    region_name='ap-south-1',
)
# response = s3_client.list_objects_v2(
#     Bucket=bucket,
#     Prefix=f'{prefix}/{batch_id}/manifest',
# )

try:
    obj = s3_client.get_object(
        Bucket=bucket,
        Key=f'{prefix}/{batch_id}/manifest',
    )
    j = obj['Body'].read().decode('utf-8')
except ClientError as ce:
    if ce.response['Error']['Code'] == 'NoSuchKey':
        print('No Such file: 202')
else:
    print(j)

# if response['Contents']:
#     file found
# else:
#     202
