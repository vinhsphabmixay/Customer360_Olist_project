WITH SOURCE AS (
    SELECT *
    FROM {{ source('olist_raw', 'RAW_OLIST_ORDERS') }}
),

RENAMED AS (
    SELECT
        order_id
        ,customer_id
        ,order_status
        ,CAST(order_purchASe_timestamp AS timestamp_ntz) AS order_purchASe_ts
        ,CAST(order_approved_at AS timestamp_ntz) AS order_approved_ts
        ,CAST(order_delivered_carrier_date AS timestamp_ntz) AS order_delivered_carrier_ts
        ,CAST(order_delivered_customer_date AS timestamp_ntz) AS order_delivered_customer_ts
        ,CAST(order_estimated_delivery_date AS timestamp_ntz) AS order_estimated_delivery_ts
    FROM SOURCE
)

SELECT * FROM RENAMED