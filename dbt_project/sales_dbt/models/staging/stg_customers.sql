{{
    config(
        materialized='view',
        schema='stg'
    )
}}

SELECT
    CUSTOMER_ID,
    FIRST_NAME,
    LAST_NAME,
    EMAIL,
    PHONE,
    REGION,
    LOYALTY_STATUS
FROM {{ source('raw', 'sales_orders') }}

