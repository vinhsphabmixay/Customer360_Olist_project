WITH ORDER_ITEMS AS (
    SELECT * FROM {{ref('stg_olist_order_items')}}
),
PRODUCTS AS (
    SELECT * FROM {{ref('stg_olist_products')}}
),
REVIEWS AS (
    SELECT * FROM {{ref('stg_olist_reviews')}}
),
ENRICHED AS (
    SELECT
        oi.ORDER_ID
        ,oi.ORDER_ITEM_ID
        ,oi.PRODUCT_ID
        ,p.PRODUCT_CATEGORY_NAME
        ,oi.PRICE
        ,oi.FREIGHT_VALUE
        ,r.REVIEW_SCORE
    FROM ORDER_ITEMS oi
    LEFT jOIN PRODUCTS p
    ON oi.PRODUCT_ID = p.PRODUCT_ID
    JOIN REVIEWS r
    ON oi.ORDER_ID = r.ORDER_ID
)

SELECT * FROM ENRICHED