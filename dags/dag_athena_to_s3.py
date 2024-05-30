import os
from datetime import timedelta
from airflow import DAG
from airflow.providers.amazon.aws.operators.athena import AthenaOperator
from airflow.providers.amazon.aws.sensors.athena import AthenaSensor
from airflow.providers.amazon.aws.operators.s3 import S3CopyObjectOperator
from airflow.utils.dates import days_ago

AWS_REGION = os.environ["AWS_DEFAULT_REGION"] = "us-east-1"
AWS_CONN_ID = "aws_default"
ATHENA_DATABASE = "" # aqui colocamos o valor do comando "terraform output athena_database"
ATHENA_WORKGROUP = "" # aqui colocamos o valor do comando "terraform output athena_workgroup"
ATHENA_OUTPUT_S3_BUCKET = "" # aqui colocamos o valor do comando "terraform output athena_output_s3_bucket"
AIRFLOW_OUTPUT_S3_BUCKET = "" # aqui colocamos o valor do comando "terraform output airflow_output_s3_bucket"

default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "email_on_failure": False,
    "email_on_retry": False,
    "retries": 0,
    "retry_delay": timedelta(minutes=5),
    "start_date": days_ago(1),
    "schedule_interval": "0 0 * * 1-5",  # Run daily at midnight except weekends
}

dag = DAG(
    "athena_to_s3",
    default_args=default_args,
    description="A DAG to filter Athena sample data and export to S3",
    catchup=False
)

create_table = AthenaOperator(
    task_id="create_table",
    query=f"""
        CREATE EXTERNAL TABLE IF NOT EXISTS cloudfrontlogs(
            `date` date,
            time string,
            location string,
            bytes int,
            request_ip string,
            method string,
            host string,
            uri string,
            status int,
            referrer string,
            os string,
            browser string,
            browser_version string
        )
        ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.RegexSerDe'
        WITH SERDEPROPERTIES (
            "input.regex" = "^(?!#)([^ ]+)\\\\s+([^ ]+)\\\\s+([^ ]+)\\\\s+([^ ]+)\\\\s+([^ ]+)\\\\s+([^ ]+)\\\\s+([^ ]+)\\\\s+([^ ]+)\\\\s+([^ ]+)\\\\s+([^ ]+)\\\\s+[^\(]+[\(]([^\;]+).*\%20([^\/]+)[\/](.*)$"
        )
        LOCATION "s3://athena-examples-{AWS_REGION}/cloudfront/plaintext/";
    """,
    database=ATHENA_DATABASE,
    workgroup=ATHENA_WORKGROUP,
    aws_conn_id=AWS_CONN_ID,
    dag=dag
)

read_table = AthenaOperator(
    task_id="read_table",
    query="""
        SELECT os, COUNT(os) os_count
        FROM cloudfrontlogs
        GROUP BY os
    """,
    database=ATHENA_DATABASE,
    workgroup=ATHENA_WORKGROUP,
    aws_conn_id=AWS_CONN_ID,
    dag=dag
)

get_read_state = AthenaSensor(
    task_id="get_read_state",
    query_execution_id=read_table.output,
    dag=dag
)

s3_export = S3CopyObjectOperator(
    task_id="copy_to_s3",
    source_bucket_key=f"s3://{ATHENA_OUTPUT_S3_BUCKET}/output/{read_table.output}.csv",
    dest_bucket_key="s3://{}/{}.csv".format(
        AIRFLOW_OUTPUT_S3_BUCKET, "{{ ds }}"
    ),
    dag=dag
)


drop_table = AthenaOperator(
    task_id="teardown__drop_table",
    query="DROP TABLE cloudfrontlogs;",
    database=ATHENA_DATABASE,
    workgroup=ATHENA_WORKGROUP,
    aws_conn_id=AWS_CONN_ID,
    dag=dag
)


create_table >> read_table >> get_read_state >> s3_export >> drop_table