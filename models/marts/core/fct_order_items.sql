WITH ITEMS AS (
    SELECT *
    FROM {{ref('int_order_items_enriched')}}
),

DIM_PRODUCT AS(
    SELECT *
    FROM {{ref('dim_product')}}
),

FINAL AS (
    SELECT
        i.ORDER_ID
        ,i.ORDER_ITEM_ID
        ,dp.PRODUCT_SK
        ,i.PRICE
        ,i.FREIGHT_VALUE
    FROM ITEMS i
    LEFT JOIN DIM_PRODUCT dp
    ON i.PRODUCT_ID = dp.PRODUCT_ID
)

SELECT * FROM FINAL