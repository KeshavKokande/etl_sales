{{
    config(
        materialized='view',
        schema='stg'
    )
}}

SELECT
    PRODUCT_ID,
    PRODUCT_NAME,
    CATEGORY,
    SUB_CATEGORY,
    BRAND,
    UNIT_COST
FROM {{ source('raw', 'sales_orders') }}