{{
    config(
        materialized='table',
        schema='final'
    )
}}

WITH ranked_tickets AS (
    SELECT
        TICKET_ID,
        TICKET_DATE,
        CUSTOMER_ID_NK,
        RESOLUTION_TIME,
        ISSUE_TYPE AS ISSUE_TYPE_NK,
        STATUS,
        ROW_NUMBER() OVER (
            PARTITION BY TICKET_ID
            ORDER BY TICKET_DATE DESC
        ) AS row_num
    FROM {{ ref('stg_tickets') }}
)

SELECT
    TICKET_ID,
    TICKET_DATE,
    CUSTOMER_ID_NK,
    RESOLUTION_TIME,
    ISSUE_TYPE_NK,
    STATUS
FROM ranked_tickets
WHERE row_num = 1
