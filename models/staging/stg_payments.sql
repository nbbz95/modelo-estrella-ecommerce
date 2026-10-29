select
    order_id,
    payment_sequential,
    payment_type,
    payment_installments              as installments,
    cast(payment_value as decimal(12, 2)) as payment_value
from {{ read_raw('olist_order_payments_dataset') }}
