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
        ,ORDER_NUMBER_FOR_CUSTOMER
        ,CASE
            WHEN ORDER_NUMBER_FOR_CUSTOMER = 1 THEN 1
            ELSE 0
        END AS IS_NEW_CUSTOMER_DAY
    FROM {{ref('fct_customer_daily_metrics')}}
)

SELECT * FROM DUMMY