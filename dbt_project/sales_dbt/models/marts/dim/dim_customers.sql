{{
    config(
        materialized='table',
        schema='final'
    )
}}

WITH ranked_customers AS (
    SELECT
        CUSTOMER_ID AS CUSTOMER_ID_NK,
        FIRST_NAME,
        LAST_NAME,
        EMAIL,
        PHONE,
        REGION,
        LOYALTY_STATUS,
        ROW_NUMBER() OVER (
            PARTITION BY CUSTOMER_ID
            ORDER BY FIRST_NAME DESC
        ) AS row_num
    FROM {{ ref('stg_customers') }}
)

SELECT
    CUSTOMER_ID_NK,
    FIRST_NAME,
    LAST_NAME,
    EMAIL,
    PHONE,
    REGION,
    LOYALTY_STATUS
FROM ranked_customers
WHERE row_num = 1
