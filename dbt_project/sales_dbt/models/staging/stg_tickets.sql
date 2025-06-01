{{
    config(
        materialized='view',
        schema='stg'
    )
}}

SELECT
    TICKET_ID,
    TICKET_DATE,
    RESOLUTION_TIME,
    ISSUE_TYPE,
    STATUS,
    CUSTOMER_ID AS CUSTOMER_ID_NK
FROM {{ source('raw', 'sales_orders') }}