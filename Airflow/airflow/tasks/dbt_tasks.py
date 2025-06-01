from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator
from airflow.utils.task_group import TaskGroup
import subprocess
import json

  
def run_dbt_and_log_rows(select_tag):
    cmd = f"cd /opt/airflow/dbt_project/sales_dbt && dbt run --select {select_tag} --log-format json"
    subprocess.run(cmd, shell=True, check=True)
    with open('/opt/airflow/dbt_project/sales_dbt/target/run_results.json') as f:
        results = json.load(f)
        for result in results['results']:
            print(f"[DBT] Model: {result['unique_id']} → Rows affected: {result.get('status', 'unknown')} - {result.get('adapter_response', {}).get('rows_affected', 'N/A')}")


def get_dbt_task_group():
    with TaskGroup("dbt_tasks", tooltip="Run and Test DBT Models") as dbt_group:
        run_stg = PythonOperator(
            task_id='dbt_run_stg', 
            python_callable=lambda: run_dbt_and_log_rows('staging')
        )
        run_marts = PythonOperator(
            task_id='dbt_run_marts', 
            python_callable=lambda: run_dbt_and_log_rows('marts')
        )
        test_marts = BashOperator(
            task_id='dbt_test_marts', 
            bash_command='cd /opt/airflow/dbt_project/sales_dbt && dbt test --select marts'
        )
        run_stg >> run_marts >> test_marts
    return dbt_group