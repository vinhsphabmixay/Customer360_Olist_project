USE DATABASE ECOMMERCE_OLIST;
USE SCHEMA RAW;
USE WAREHOUSE WH_OLIST;

-- Customers
CREATE OR REPLACE TABLE RAW.RAW_OLIST_CUSTOMERS (
    customer_id                 STRING
    ,customer_unique_id         STRING
    ,customer_zip_code_prefix   STRING
    ,customer_city              STRING
    ,customer_state             STRING
);

--Orders
CREATE OR REPLACE TABLE RAW.RAW_OLIST_ORDERS (
    order_id                        STRING
    ,customer_id                    STRING
    ,order_status                   STRING
    ,order_purchase_timestamp       TIMESTAMP_NTZ
    ,order_approved_at              TIMESTAMP_NTZ
    ,order_delivered_carrier_date   TIMESTAMP_NTZ
    ,order_delivered_customer_date  TIMESTAMP_NTZ
    ,order_estimated_delivery_date  TIMESTAMP_NTZ
);

--Order lines
CREATE OR REPLACE TABLE RAW.RAW_OLIST_ORDER_ITEMS (
    order_id                STRING
    ,order_item_id          NUMBER
    ,product_id             STRING
    ,seller_id              STRING
    ,shipping_limit_date    TIMESTAMP_NTZ
    ,price                  NUMBER(10,2)
    ,freight_value          NUMBER(10,2)
);

--Payments
CREATE OR REPLACE TABLE RAW.RAW_OLIST_ORDER_PAYMENTS (
    order_id                STRING
    ,payment_sequential     NUMBER
    ,payment_type           STRING
    ,payment_installments   NUMBER
    ,payment_value          NUMBER(10,2)
);

--Products
CREATE OR REPLACE TABLE RAW.RAW_OLIST_PRODUCTS(
    product_id                      STRING
    ,product_category_name          STRING
    ,product_name_length            NUMBER
    ,product_description_length     NUMBER
    ,product_photos_qty             NUMBER
    ,product_weight_g               NUMBER
    ,product_length_cm              NUMBER
    ,product_height_cm              NUMBER
    ,product_width_cm               NUMBER
);

--Reviews
CREATE OR REPLACE TABLE RAW.RAW_OLIST_ORDER_REVIEWS(
    review_id                   STRING
    ,order_id                   STRING
    ,review_score               NUMBER
    ,review_comment_title       STRING
    ,review_comment_message     STRING
    ,review_creation_date       TIMESTAMP_NTZ
    ,review_answer_timestamp    TIMESTAMP_NTZ
);

--Geolocation
CREATE OR REPLACE TABLE RAW.RAW_OLIST_GEOLOCATION(
    geolocation_zip_code_prefix     NUMBER  
    ,geolocation_lat                FLOAT
    ,geolocation_lng                FLOAT
    ,geolocation_city               STRING
    ,geolocation_state              STRING
);

--Sellers
CREATE OR REPLACE TABLE RAW.RAW_OLIST_SELLERS(
    seller_id                   STRING
    ,seller_zip_code_prefix     NUMBER
    ,seller_city                STRING
    ,seller_state               STRING
);

CREATE OR REPLACE TABLE RAW.RAW_PRODUCT_CATEGORY_NAME_TRANSLATION(
    product_category_name           STRING
    ,product_category_name_english  STRING
);