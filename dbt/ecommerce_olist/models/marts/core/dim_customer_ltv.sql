{{config(materialized = 'view')}}

WITH DUMMY AS (
    SELECT
        CUSTOMER_SK
        ,DATE
        ,DATE_MONTH
        ,ORDERS_COUNT
        ,DAILY_REVENUE
        ,CUMULATIVE_ORDERS_COUNT
        ,CUMULATIVE_REVENUE
        ,MAX(CUMULATIVE_REVENUE) OVER (PARTITION BY CUSTOMER_SK) AS LTV
    FROM {{ref('fct_customer_daily_metrics')}}
)

SELECT * FROM DUMMY