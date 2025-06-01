{{
    config(
        materialized='table',
        schema='final'
    )
}}

WITH ranked_orders AS (
    SELECT
        ORDER_ID,
        ORDER_DATE,
        CUSTOMER_ID AS CUSTOMER_ID_NK,
        PRODUCT_ID AS PRODUCT_ID_NK,
        STORE_ID AS STORE_ID_NK,
        EMPLOYEE_ID AS EMPLOYEE_ID_NK,
        QUANTITY,
        UNIT_PRICE,
        DISCOUNT,
        TOTAL_PRICE,
        PAYMENT_METHOD,
        ROW_NUMBER() OVER (
            PARTITION BY ORDER_ID
            ORDER BY CUSTOMER_ID DESC
        ) AS row_num
    FROM {{ ref('stg_order') }}
)

SELECT
    ORDER_ID,
    ORDER_DATE,
    CUSTOMER_ID_NK,
    PRODUCT_ID_NK,
    STORE_ID_NK,
    EMPLOYEE_ID_NK,
    QUANTITY,
    UNIT_PRICE,
    DISCOUNT,
    TOTAL_PRICE,
    PAYMENT_METHOD
FROM ranked_orders
WHERE row_num = 1