{{
    config(
        materialized='table',
        schema='final'
    )
}}

WITH ranked_stores AS (
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
            PAYMENT_METHOD,
        ROW_NUMBER() OVER (
            PARTITION BY ORDER_ID
            ORDER BY EMPLOYEE_ID DESC
        ) AS row_num
    FROM {{ ref('stg_order') }}
    WHERE store_id IS NOT NULL
)

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
FROM ranked_stores
WHERE row_num = 1