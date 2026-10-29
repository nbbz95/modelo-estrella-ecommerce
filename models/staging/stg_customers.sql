select
    customer_id,
    customer_unique_id,
    lpad(cast(customer_zip_code_prefix as varchar), 5, '0') as zip_prefix,
    customer_city  as city,
    customer_state as state
from {{ read_raw('olist_customers_dataset') }}
