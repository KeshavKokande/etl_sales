{{ config(
    materialized='view',
    schema='stg'
) }}

SELECT
    ORDER_ID,
    ORDER_DATE,
    CUSTOMER_ID,
    PRODUCT_ID,
    STORE_ID,
    EMPLOYEE_ID,
    QUANTITY,
    UNIT_PRICE,
    DISCOUNT,
    TOTAL_PRICE,
    PAYMENT_METHOD
FROM {{ source('raw', 'sales_orders') }}
