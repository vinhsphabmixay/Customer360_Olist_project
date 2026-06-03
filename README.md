# Customer 360 e-commerce - Olist (Snowflake, DBT, Airflow & Data Studio [Previously Looker Studio])

This project is an analytical platform of type **Customer 360** build from a public dataset **Brazilian E-Commerce by Olist** (and its linked **Marketing Funnel Olist**)
The goal is to simulate a Data Engineering production environment : Data ingestion in Snowflake, Data Modeling with DBT (staging &rarr; intermediate &rarr; marts), orchestration with Airflow (Docker) and exploitation with dashboards in Data Studio.

The pipeline answers business questions such as :
- Who are my most profiatble customers (LTV, RFM) ?
- How are sells trending by product / category / region ?
- Who are the best performing sellers ?
- How is marketing performance (MQL &rarr; deals) translated in business ?

---

## 1. Général architecture

Overview of the solution :

1. **Raw  data**
   - CSV Kaggle "[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)"
   - CSV Kaggle "[Marketing Funnel by Olist](https://www.kaggle.com/datasets/olistbr/marketing-funnel-olist)"

2. **Storage & computation**
   - **Snowflake** as a Data Warehouse (RAW / STAGING / MARTS schemas)
   - Data loaded via 'COPY INTO' from an internal stage after being loaded into a stage under a schema. Example :
```
COPY INTO RAW.RAW_OLIST_CUSTOMERS
FROM '@"ECOMMERCE_OLIST"."RAW"."STG_OLIST"/olist_customers_dataset.csv'
FIlE_FORMAT = (FORMAT_NAME = RAW.CSV_OLIST_FORMAT);
```
The SQL files for tables creation and data loading are available

3. **Transformation**
   - **dbt Core** for medling and data quality
   - Logical architecture : `staging/` &rarr; `intermediate/` &rarr; `marts/`

4. **Orchestration**
   - **Apache Airflow** (Docker-compose, LocalExecuctor)
   - Daily DAG that execues `dbt clean` &rarr; `dbt deps` &rarr; `dbt build` &rarr; `dbt docs generate`
  
5. **Visualization**
   - **Looker Studio** connected to Snowflake (official)
   - Two main dashboards : **Customer 360** and **Sales & Products**
  
---

## 2. Dataset

### 2.1 Olist e-commerce

Public Kaggle dataset "Brazilian E-Commerce Public Dataset by Olist":

- ~100k orders (2016-2018) on a Brazilian marketplace
- Main tables :
  - `olist_customers_dataset`
  - `olist_orders_dataset`
  - `olist_order_items_dataset`
  - `olist_order_payments_dataset`
  - `olist_products_dataset`
  - `olist_order_reviews_dataset`
  - `olist_sellers_dataset`
  - `olist_geolocation_dataset`

These CSV files are loaded in the **RAW** schema in Snowflake (`RAW_OLIST_`)

### 2.2 Olist Marketing Funnel

Public Kaggle Dataset "Marketing Funnel by Olist"

- Leads MQL, deals, marketing information
- Main tables :
  - `olist_marketing_qualified_leads_dataset`
  - `olist_closed_deals_dataset`
 
These CSV files are loaded in the tables `RAW_OLIST_LEADS` and `RAW_OLIST_DEALs`

---

## 3. Data Modeling (dbt)

The dbt project follows dbt good practices : clear dissociation between **sources**, **staging**, **intermediate** and **marts**.

### 3.1 Sources (RAW)

Defined in `models/staging/olist/src_olist.yml`

- Source `olist_raw` pointant vers `ECOMMERCE_OLIST.RAW`
- Tables sources :
  - `RAW_OLIST_CUSTOMERS`
  - `RAW_OLIST_ORDERS`
  - `RAW_OLIST_ORDER_ITEMS`
  - `RAW_OLIST_ORDER_PAYMENTS`
  - `RAW_OLIST_ORDER_REVIEWS`
  - `RAW_OLIST_PRODUCTS`
  - `RAW_OLIST_SELLERS`
  - `RAW_OLIST_GEOLOCATION`
  - `RAW_OLIST_LEADS`
  - `RAW_OLIST_DEALS`
  - `RAW_PRODUCT_CATEGORY_NAME_TRANSLATION`

`not_null`, `unique` and `relationships` tests have been applied to check the minimum coherence of raw data (order/customer relations, order/lines etc).
Some constraints have deliberately been moved to staging/intermediate to manage the imperfect reality of data.

### 3.2 Transformation layers

#### Staging (`models/staging/olist/`)

- `stg_olist` models:
  - column renaming,
  - data type casting  (dates, numbers)
  - deletion/deduplication of simple anomalies (ex. duplicated reviews)
  - No complex join : each model reflects one source with a clean schema
 
#### Intermediate (`models/intermediate/`)

**Business logic** oriented models and reusable :

- **Orders & Payments**
  - `int_payments_pivoted_to_orders` : aggregates payments by order (`total_payment_value`, `payments_count`),
  - `int_orders_enriched` : joins orders + clients + payments, computes metrics such as `delivery_delay_days`
  - 
- **Order items / products**
  - `int_order_items_enriched` : order lines enriched with products (categories, etc)

- **Aggregation by customer & seller**
  - `int_customer_orders_agg` : aggregates by customer (`orders_count`, `total_revenue`, `first_order_ts`, `last_order_ts`),
  - `int_seller_orders_agg`

























