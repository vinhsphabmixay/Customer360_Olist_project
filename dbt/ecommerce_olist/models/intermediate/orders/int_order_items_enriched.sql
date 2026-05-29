WITH ORDER_ITEMS AS (
    SELECT * FROM {{ref('stg_olist_order_items')}}
),
PRODUCTS AS (
    SELECT * FROM {{ref('stg_olist_products')}}
),
ENRICHED AS (
    SELECT
        oi.ORDER_ID
        ,oi.ORDER_ITEM_ID
        ,oi.PRODUCT_ID
        ,p.PRODUCT_CATEGORY_NAME
        ,oi.PRICE
        ,oi.FREIGHT_VALUE
    FROM ORDER_ITEMS oi
    LEFT jOIN PRODUCTS p
    ON oi.PRODUCT_ID = p.PRODUCT_ID
)

SELECT * FROM ENRICHED