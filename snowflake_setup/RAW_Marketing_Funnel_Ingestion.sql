USE DATABASE ECOMMERCE_OLIST;
USE SCHEMA RAW;
USE WAREHOUSE WH_OLIST;

CREATE OR REPLACE TABLE RAW.RAW_OLIST_LEADS(
    mql_id                  STRING
    ,first_contact_date     DATE
    ,landing_page_id        STRING
    ,origin                 STRING
);

CREATE OR REPLACE TABLE RAW.RAW_OLIST_DEALS(
    mql_id                              STRING
    ,seller_id                          STRING
    ,sdr_id                             STRING
    ,sr_id                              STRING
    ,won_date                           DATE
    ,business_segment                   STRING
    ,lead_type                          STRING
    ,lead_behaviour_profile             STRING
    ,has_company                        STRING
    ,has_gtin                           STRING
    ,average_stock                      STRING
    ,business_type                      STRING
    ,declared_product_catalog_size      STRING
    ,declared_monthly_revenue           STRING
)