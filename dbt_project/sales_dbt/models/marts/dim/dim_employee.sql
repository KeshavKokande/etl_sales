{{ config(
    materialized='table',
    schema='final'
) }}

WITH ranked_employees AS (
    SELECT
        EMPLOYEE_ID AS EMPLOYEE_ID_NK,
        ROLE,
        ROW_NUMBER() OVER (
            PARTITION BY EMPLOYEE_ID
            ORDER BY ROLE DESC
        ) AS row_num
    FROM {{ source('raw', 'sales_orders') }}
)

SELECT
    EMPLOYEE_ID_NK,
    ROLE
FROM ranked_employees
WHERE row_num = 1
