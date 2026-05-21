WITH BASE AS(
    SELECT
        PRODUCT_ID
        ,PRODUCT_CATEGORY_NAME
        ,PRODUCT_NAME_LENGTH
        ,PRODUCT_DESCRIPTION_LENGTH
        ,PRODUCT_PHOTOS_QTY
        ,PRODUCT_WEIGHT_G
        ,PRODUCT_LENGTH_CM
        ,PRODUCT_HEIGHT_CM
        ,PRODUCT_WIDTH_CM
    FROM {{ref('stg_olist_products')}}
),

FINAL AS (
    SELECT
        {{dbt_utils.generate_surrogate_key(['PRODUCT_ID'])}} AS PRODUCT_SK
        ,*
    FROM BASE
)

SELECT * FROM FINAL