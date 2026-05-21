WITH LEADS AS (
    SELECT * FROM {{ref('stg_olist_leads')}}
),
DEALS AS (
    SELECT * FROM {{ref('stg_olist_deals')}}
),
JOINED AS (
    SELECT
        l.MQL_ID
        ,l.FIRST_CONTACT_DATE
        ,l.LANDING_PAGE_ID
        ,l.ORIGIN
        ,d.WON_DATE_TS
        ,d.BUSINESS_SEGMENT
        ,d.LEAD_TYPE
        ,d.LEAD_BEHAVIOUR_PROFILE
        ,d.SELLER_ID
        ,CASE WHEN d.WON_DATE_TS IS NOT NULL THEN 1 ELSE 0 END IS_WON
    FROM LEADS l
    LEFT JOIN DEALS d
    ON l.MQL_ID = d.MQL_ID
)

SELECT * FROM JOINED