{{config(materialized = 'view')}}

WITH DUMMY AS (
    SELECT
        
    FROM {{ref('fct_customer_daily_metrics')}}
)

SELECT * FROM DUMMY