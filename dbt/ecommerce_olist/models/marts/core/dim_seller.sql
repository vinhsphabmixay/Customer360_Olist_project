WITH BASE AS (
    SELECT
        *
    FROM {{ref('stg_olist_sellers')}}
),

ORDERS_AGG AS(
    SELECT * FROM {{ref('int_seller_orders_agg')}}
),

FINAL AS(
    SELECT
        {{dbt_utils.generate_surrogate_key(['b.SELLER_ID'])}} AS SELLER_SK
        ,b.SELLER_ID
        ,b.SELLER_ZIP_CODE_PREFIX
        ,b.SELLER_CITY
        ,b.SELLER_STATE

        ,oa.FIRST_ORDER_TS_SELLER
        ,oa.LAST_ORDER_TS_SELLER
        ,oa.ORDERS_COUNT_SELLER
        ,oa.REVENUE_SELLER
        ,oa.GMVS_SELLER
        ,oa.AVG_REVIEW_SCORE_SELLER
    FROM BASE b
    JOIN ORDERS_AGG oa
    ON b.SELLER_ID = oa.SELLER_ID
)

SELECT * FROM FINAL