from airflow.operators.python import PythonOperator
import requests

def get_quote_task():
    return PythonOperator(
        task_id='print_random_quote',
        python_callable=lambda: print(f"Quote of the day: '{requests.get('https://api.quotable.io/random', verify=False).json()['content']}'")
    )
