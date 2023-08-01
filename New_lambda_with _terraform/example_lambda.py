import boto3
import datetime
import os
import logging

# Configure the logger
logger = logging.getLogger()
logger.setLevel(logging.INFO)

RETENTION_DAYS = int(os.environ['RETENTION_DAYS'])

def handler(event, context):
    region = boto3.Session().region_name  
    rds_client = boto3.client('rds', region_name=region)

    current_date = datetime.datetime.now().replace(tzinfo=None)

    delete_before_date = current_date - datetime.timedelta(days=RETENTION_DAYS)
    logger.info(delete_before_date.strftime("%d/%m/%Y"))

    response = rds_client.describe_db_snapshots(SnapshotType='manual')

    for snapshot in response['DBSnapshots']:
        snapshot_date = snapshot['SnapshotCreateTime'].replace(tzinfo=None)
        logger.info(f"Snapshot Date: {snapshot_date}, Snapshot Identifier: {snapshot['DBSnapshotIdentifier']}")
        if snapshot_date <= delete_before_date:
            logger.info(f"Deleting snapshot {snapshot['DBSnapshotIdentifier']}")
            # rds_client.delete_db_snapshot(DBSnapshotIdentifier=snapshot['DBSnapshotIdentifier'])
        else:
            logger.info(f"Not deleting snapshot {snapshot['DBSnapshotIdentifier']}")
