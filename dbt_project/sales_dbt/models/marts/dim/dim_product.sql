{{
    config(
        materialized='table',
        schema='final'
    )
}}

WITH ranked_products AS (
    SELECT
        PRODUCT_ID AS PRODUCT_ID_NK,
        PRODUCT_NAME,
        CATEGORY,
        SUB_CATEGORY,
        BRAND,
        UNIT_COST,
        ROW_NUMBER() OVER (
            PARTITION BY PRODUCT_ID
            ORDER BY PRODUCT_NAME DESC
        ) AS row_num
    FROM {{ ref('stg_products') }}
)

SELECT
    PRODUCT_ID_NK,
    PRODUCT_NAME,
    CATEGORY,
    SUB_CATEGORY,
    BRAND,
    UNIT_COST
FROM ranked_products
WHERE row_num = 1
