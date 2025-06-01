-- 5. dim_issue_type.sql
{{
    config(
        materialized='table',
        schema='final'
    )
}}

SELECT DISTINCT
    ISSUE_TYPE AS ISSUE_TYPE_NK,
    STATUS
FROM {{ ref('stg_tickets') }}