WITH DATE_TABLE AS (
    {{ dbt_utils.date_spine(
        datepart = "month",
        start_date = "'2016-09-01'::date",
        end_date   = "'2018-10-01'::date"
    ) }}
)

SELECT date_month FROM DATE_TABLE