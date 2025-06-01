from airflow.operators.python import PythonOperator
from datetime import datetime

def get_welcome_tasks():
    print_welcome = PythonOperator(
        task_id='print_welcome',
        python_callable=lambda: print("Welcome to Airflow!")
    )

    print_date = PythonOperator(
        task_id='print_date',
        python_callable=lambda: print(f"Today is {datetime.today().date()}")
    )

    return print_welcome, print_date