import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), "..")) 
from airflow import DAG
from datetime import datetime, timedelta

from tasks.welcome_tasks import get_welcome_tasks
from tasks.clean_load_tasks import clean_csv, load_to_snowflake_incremental
from tasks.dbt_tasks import get_dbt_task_group
from tasks.quote_task import get_quote_task
from airflow.operators.python import PythonOperator

default_args = {
    'start_date': datetime(2024, 1, 1),
    'retries': 1,
    'retry_delay': timedelta(minutes=2),
}

with DAG(
    dag_id='combined_pipeline_dag',
    default_args=default_args,
    schedule="@daily",
    catchup=False,
    tags=['mockkaro'],
) as dag:

    print_welcome, print_date = get_welcome_tasks()

    clean_task = PythonOperator(task_id='clean_data', python_callable=clean_csv)
    load_task = PythonOperator(task_id='load_incremental_to_snowflake', python_callable=load_to_snowflake_incremental)

    dbt_group = get_dbt_task_group()
    quote_task = get_quote_task()

    print_welcome >> print_date >> clean_task >> load_task >> dbt_group >> quote_task
