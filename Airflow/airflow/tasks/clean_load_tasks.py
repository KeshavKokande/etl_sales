import pandas as pd
import os
import snowflake.connector
from airflow.operators.python import PythonOperator

def clean_csv():
    df = pd.read_csv('/opt/airflow/MOCK_DATA.csv')
    df.columns = df.columns.str.strip().str.lower().str.replace(' ', '_')
    df.dropna(subset=['customer_id', 'employee_id'], inplace=True)
    df['first_name'] = df['first_name'].fillna('Unknown')
    df['last_name'] = df['last_name'].fillna('Unknown')
    df.to_csv('/opt/airflow/cleaned_sales_data.csv', index=False)
    print(f"[Clean Task] Records after cleaning: {len(df)}")


def load_to_snowflake_incremental():
    conn = snowflake.connector.connect(
        user=os.environ['SNOWFLAKE_USER'],
        password=os.environ['SNOWFLAKE_PASSWORD'],
        account=os.environ['SNOWFLAKE_ACCOUNT'],
        warehouse=os.environ['SNOWFLAKE_WAREHOUSE'],
        database=os.environ['SNOWFLAKE_DATABASE'],
        schema=os.environ['SNOWFLAKE_SCHEMA']
    )
    cur = conn.cursor()
    insert_count = 0
    cur.execute("CREATE OR REPLACE TEMP TABLE sales_orders_stage LIKE sales_orders")

    with open('/opt/airflow/cleaned_sales_data.csv', 'r') as f:
        headers = next(f).strip().split(',')
        for line in f:
            values = [x.strip() for x in line.strip().split(',')]
            placeholders = ', '.join(["%s"] * len(values))
            cur.execute(f"INSERT INTO sales_orders_stage VALUES ({placeholders})", values)
            insert_count += 1

    cur.execute("""
        MERGE INTO sales_orders AS target
        USING sales_orders_stage AS source
        ON target.order_id = source.order_id
        WHEN MATCHED THEN UPDATE SET
            order_date = source.order_date,
            customer_id = source.customer_id,
            product_id = source.product_id,
            store_id = source.store_id,
            employee_id = source.employee_id,
            quantity = source.quantity,
            unit_price = source.unit_price,
            discount = source.discount,
            total_price = source.total_price,
            payment_method = source.payment_method,
            ticket_id = source.ticket_id,
            ticket_date = source.ticket_date,
            resolution_time = source.resolution_time,
            issue_type = source.issue_type,
            status = source.status,
            first_name = source.first_name,
            last_name = source.last_name,
            email = source.email,
            phone = source.phone,
            region = source.region,
            loyalty_status = source.loyalty_status,
            product_name = source.product_name,
            category = source.category,
            sub_category = source.sub_category,
            brand = source.brand,
            unit_cost = source.unit_cost,
            store_name = source.store_name,
            city = source.city,
            role = source.role
        WHEN NOT MATCHED THEN INSERT VALUES (
            source.order_id, source.order_date, source.customer_id,
            source.product_id, source.store_id, source.employee_id,
            source.quantity, source.unit_price, source.discount,
            source.total_price, source.payment_method, source.ticket_id,
            source.ticket_date, source.resolution_time, source.issue_type,
            source.status, source.first_name, source.last_name,
            source.email, source.phone, source.region, source.loyalty_status,
            source.product_name, source.category, source.sub_category,
            source.brand, source.unit_cost, source.store_name, source.city, source.role
        )
    """)

    cur.close()
    conn.close()
    print("Incremental load completed via MERGE.")
    print(f"[Load Task] Total records loaded into Snowflake: {insert_count}")
