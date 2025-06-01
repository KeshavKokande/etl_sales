{{
    config(
        materialized='table',
        schema='final'
    )
}}

WITH customer_spending AS (
    SELECT
        CUSTOMER_ID_NK,
        SUM(TOTAL_PRICE) AS TOTAL_SPENT,
        COUNT(DISTINCT ORDER_ID) AS TOTAL_ORDERS,
        MAX(ORDER_DATE) AS LAST_ORDER_DATE
    FROM {{ ref('fact_order') }}
    GROUP BY CUSTOMER_ID_NK
),
ranked_customers AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY CUSTOMER_ID_NK
            ORDER BY TOTAL_SPENT DESC
        ) AS row_num
    FROM customer_spending
)

SELECT
    CUSTOMER_ID_NK,
    TOTAL_SPENT,
    TOTAL_ORDERS,
    LAST_ORDER_DATE
FROM ranked_customers
WHERE row_num = 1
