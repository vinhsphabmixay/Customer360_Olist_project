import datetime
from airflow import DAG
from airflow.operators.bash import BashOperator

default_args = {
    "owner": "vinhsphabmixay",
    "start_date": datetime.datetime(2024, 1, 1),
    "retries": 1,
    "retry_delay": datetime.timedelta(minutes=5)
}

with DAG(
    dag_id = "ecommerce_olist_dbt",
    default_args = default_args,
    schedule_interval = "@daily",
    catchup = False
) as dag:
    
    dbt_clean = BashOperator(
        task_id = "dbt_clean",
        bash_command = "cd /opt/airflow/dbt/ecommerce_olist && dbt clean",
    )

    dbt_deps = BashOperator(
        task_id = "dbt_deps",
        bash_command = "cd /opt/airflow/dbt/ecommerce_olist && dbt deps",
    )

    dbt_build = BashOperator(
        task_id = "dbt_build",
        bash_command = "cd /opt/airflow/dbt/ecommerce_olist && dbt build",
    )

    dbt_docs = BashOperator(
        task_id = "dbt_docs_generate",
        bash_command = "cd /opt/airflow/dbt/ecommerce_olist && dbt docs generate",
    )

    dbt_clean >> dbt_deps >> dbt_build >> dbt_docs