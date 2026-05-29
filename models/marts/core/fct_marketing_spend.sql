WITH LEADS AS(
    SELECT
        MQL_ID
        ,FIRST_CONTACT_DATE
        ,ORIGIN
        ,SELLER_ID
        ,IS_WON
    FROM {{ref('int_leads_with_deals')}}
),

DIM_SELLER AS (
    SELECT
        SELLER_SK
        ,SELLER_ID
    FROM {{ref('dim_seller')}}
),

AGG AS (
    SELECT
        l.FIRST_CONTACT_DATE::DATE AS DATE
        ,s.SELLER_SK
        ,l.ORIGIN

        ,COUNT(*) AS MQL_COUNT
        ,SUM(CASE WHEN l.IS_WON = 1 THEN 1 ELSE 0 END) AS WON_MQL_COUNT
        ,CASE
            WHEN COUNT(*) = 0 THEN 0
            ELSE SUM(CASE WHEN l.IS_WON = 1 THEN 1 ELSE 0 END)::FLOAT / COUNT(*)
        END AS MQL_TO_DEAL_CONV_RATE
    FROM LEADS l
    LEFT JOIN DIM_SELLER s
    ON l.SELLER_ID = s.SELLER_ID
    GROUP BY
        l.FIRST_CONTACT_DATE::DATE
        ,s.SELLER_SK
        ,l.ORIGIN
),

FINAL AS (
    SELECT
        DATE
        ,DATE_TRUNC('month', DATE)::DATE AS DATE_MONTH
        ,ORIGIN
        ,SELLER_SK
        ,MQL_COUNT
        ,WON_MQL_COUNT
        ,MQL_TO_DEAL_CONV_RATE
    FROM AGG
    ORDER BY DATE, ORIGIN, SELLER_SK
)

SELECT * FROM FINAL