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
```SQL
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

- **Customer & seller aggregations**
  - `int_customer_orders_agg` : aggregates by customer (`orders_count`, `total_revenue`, `first_order_ts`, `last_order_ts`),
  - `int_seller_orders_agg`

- **Marketing funnel**
   - `int_leads_with_deals` : joins leads (MQL) and deals, creates an `is_won` flag
   - `int_marketing_funnel_joined` : aggregates the funnel at seller level to link marketing and sells

#### Marts (`models/marts/`)

##### Dimensions

- `dim_customer`
   - Grain = `customer_unique_id`
   - Attributes : city, state, `first_order_ts`, `last_order_ts`, `orders_count`, `total_revenue`, `avg_order_value`
   - Surrogate key : `customer_sk`

- `dim_product`
   - Grain : `product_id`
   - Product attributes : category, length, width, etc
   - Enriched with `int_order_items_enriched` : `revenue_product`, `avg_price`
   - Surrogate key : `product_sk`

- `dim_seller`
   - Grain = `seller_id`
   - Attributes : location, aggregated metrics (orders count, seller total revenue, etc)
   - Surrogate key : `seller_sk`

- `dim_date`
   - Generated via `dbt_utils.date_spine` between 2016-06-01 and 2018-10-01 (monthly grain)
 
##### Facts

- `fct_orders`
   - Grain = `order_id`
   - Attributes : `customer_sk`, `order_purchase_ts`, `order_status`, `order_revenue`, `payments_count`, delivery metrics (delay, lateness vs estimate)

- `fct_order_items`
   - Grain = order line (`order_id`,`order_item_id`)
   - Attributes : `product_sk`, `price`, `freight_value`

- `fct_customer_daily_metrics`
   - Grain = customer x day (`customer_sk`, `date`)
   - Attributes :
      - `orders_count` and `daily_revenue` of day
      - `cumulative_orders_count` (cumulative amount of orders)
      - `cumulative_revenue` (partial cumulated LTV)
      - `order_number_for_customer` (order rank)
      - `is_first_order_for_customer`, `is_last_order_for_customer`

- `fct_marketing_spend`
   - Grain = date x origin x seller (`date`, `origin`, `seller_sk`)
   - Attributes : `mql_count`, `won_mql_count`, `mql_to_deal_conv_rate`
   - On the long run, this table can have real spend columns if a marketing cost source is added

Files such as `src_olist.yml`, `_int_olist_models.yml` and `marts_model.sql` detail and test the models, with descriptions and relationships tests.

---

## 4. Airflow Orchestration (Docker-compose)

### 4.1 Airflow Stack

Airflow runs locally with **Docker-compose** :

- Services :
   - `postgres` : Airflow metadatabase
   - `airflow-webserver` : Airflow UI on `localhost:8080`
   - `airflow-scheduler` : Scheduler (LocalExecutor)
   - `airflow-init` : Initialisation (Database + Admin user)

- The dbt project is mounted in a countainer, for example in `/opt/airflow/dbt/ecommerce_olist`
- `dbt-core` and `dbt-snowflake` are installed in the image via `_PIP_ADDITIONAL_REQUIREMENTS`

### 4.2 DAG `ecommerce_olist_dbt`

The main DAG `ecommerce_olist_dbt` orchestrates the dbt pipeline :

Main tasks :

1. `dbt_clean`
   - Cleans `target/` and `dbt_packages/`

2. `dbt_deps`
   - Installs/updates dbt packages (ex. `dbt_utils`)

3. `dbt_build`
   - Executes all transformations and dbt tests (sources &rarr; staging &rarr; intermediate &rarr; marts)

4. `dbt_docs_generate`
   - Generates HTML documentation of the project (DAG, schemas, descriptions)

Dependencies :

```python
dbt_clean >> dbt_deps >> dbt_build >> dbt_docs_generate
```

The DAG is planned as `@daily` (can be manually triggered locally)

---

## 5. Data Studio dashboards (previously Looker Studio)

The project has 2 main Data Studio dashboards connected to Snowflake.

### 5.1 Customer 360 Dashboard

**Data source** :  `fct_customer_daily_metrics` + `dim_customer` juncture

Main blocs :
- **Global filters**
   - Date span (based on `date`)
   - State (`customer_state`), city (`customer_city`)

- **KPIs** :
   - Active customers count
   - Customers revenue
   - Number of new customers over date span (via `first_order_ts`)
   - Estimated churn rate (clients without order since X days)

- **Activity over time**
   - "Active customer per day" graph
   - "Customer revenue per day" graph

- **Segmentation** :
   - Recency and frequency buckets (light RFM) and customer distribution by segment
   - Proportion of customer by location

- **Detailed view** :
   - Customer table (ID, location, `orders_count`, `total_revenue`, `avg_order_value`, `first_order_ts`, `last_order_ts`, `cumulative_revenue`)

- **Customer location** :
   - Customer city pie chart
 
### 5.2 Sales & Products dashboard

**Data source** : `fct_orders` + `fct_order_items` + `dim_product` + `dim_customer` juncture

Main blocs :
- **KPIs** :
   - Total revenue
   - Orders count
   - Average shopping cart
   - Number of products sold

- **Activity over time** :
   - Monthly revenue
   - Monthly orders count

- **Product & Categories analysis**
   - Top selling categories by revenue
   - Top selling products by revenue and volume
   - Fastest delivery delay by categories

- **Logistics and customer satisfaction**
   - Order review score pie chart
   - Order status pie chart

- **Detailed view** :
   - Order lines table (order, date, status, category, product id, price, freight value and order revenue)

---

## 6. Repo structure

```text
.
├── docker-compose.yml
├── docs/
|   ├── architecture.png
|   ├── dashboard_customer360.png
|   └── dashboard_sales_products.png
├── dags/
│   └── ecommerce_olist_dbt.py
├── dbt/
│   └── ecommerce_olist/
│       ├── dbt_project.yml
|       └── packages.yml
│       ├── models/
│       │   ├── exposures/
|       |   |   └── customer360.yml
│       │   ├── staging/
│       │   │   └── olist/
│       │   │       ├── src_olist.yml
│       │   │       ├── stg_olist_orders.sql
│       │   │       ├── stg_olist_customers.sql
│       │   │       └── ...
│       │   ├── intermediate/
│       │   │   ├── _int_olist_models.yml
│       │   │   ├── orders/
│       │   │   │   ├── int_orders_enriched.sql
│       │   │   │   └── int_payments_pivoted_to_orders.sql
│       │   │   ├── customers/
│       │   │   │   └── int_customer_orders_agg.sql
│       │   │   ├── marketing
|       |   |   |   ├── int_leads_with_deals.sql
|       |   |   |   └── int_marketing_funnel_joined.sql
│       │   └── marts/
│       │       ├── core/
│       │       │   ├── dim_customer.sql
│       │       │   ├── dim_product.sql
│       │       │   ├── dim_seller.sql
│       │       │   ├── dim_channel.sql
│       │       │   ├── dim_date.sql
│       │       │   ├── fct_orders.sql
│       │       │   ├── fct_order_items.sql
│       │       │   ├── fct_customer_daily_metrics.sql
│       │       │   ├── fct_marketing_spend.sql
│       │       |   └── mart_models.yml
│       ├── macros/
│       ├── seeds/
│       └── ...
├── logs/
└── plugins/

```

---

## 7. Prerequisites

- Docker + Docker-compose
- Snowflake account (trial is fine)
- dbt Core + dbt-snowflake (installed in an Airflow container via `_PIP_ADDITIONAL_REQUIREMENTS`
- Access to Data Studio [previously Looker Studio] (Google account)

---

## 8. Executing the project

1. **Clone repo**

```bash
git clone <repo_url>
cd <repo>
```

2. **Configure Snowflake**

- Create a `ECOMMERCE_OLIST` database, a role and a warehouse
- Create RAW tables (`RAW_OLIST_*`) and load Olist + Marketing Funnel CSVs via `COPY_INTO`

3. **Configure dbt**

- Create a `profiles.yml` file for Snowflake with credentials
- Test local connection (optionnal)

```bash
cd dbt/ecommerce_olist
dbt debug
```

4. **Run Airflow**

```bash
docker-compose up airflow init
docker-compose up -d
```

5. **Run pipeline**

- Go to `localhost:8080`, connect to Airflow
- Activate the `ecommerce_olist_dbt` DAG
- Manual run : the pipeline will run `dbt_clean` &rarr; `dbt_deps` &rarr; `dbt_build` &rarr; `dbt_docs_generate`

6. **Visualize data**

- In Snowflake, check tables `ECOMMERCE_OLIST.MARTS.*`
- In Looker Studio, create Snowflake data sources based on marts tables (or SQL queries) then build the Customer 360 and Sales & Products dashboards.

---

## 9. To go further

If this were a production proiject, those are possible areas for improvement:

- **Automated Ingestion**
   - Use Snowpipe + Google Cloud Storage instead of manual changes
   - Events system (Pub/Sub) for auto-ingest
     
- **Data Quality & Observability**
   - Extend dbt tests (freshness, business constraints, expected volumes)
   - Add Airflow alerts (email/Slack) in case of failure

- **Advanced modeling**
   - More complete RFM, churn scoring, automatic segmentation if data is more complete
   - Web events table (sessions, complete funnel)

- **Cost & Performance**
   - Optimize Snowflake requests

---

## 10. Contact

If this project piqued your curiosity or convinced you of my self-teaching and Data Engineering capabilities, feel free to contact me :
- LinkedIn : <details> <summary> See link </summary> https://www.linkedin.com/in/ltv-sphabmixay/ <details>
- Email : <details> <summary> See email </summary> letienvinh.sphabmixay@gmail.com <details>






























