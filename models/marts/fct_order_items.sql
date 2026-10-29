-- Grano: una línea de orden (producto dentro de una orden).
with items as (
    select * from {{ ref('stg_order_items') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
)

select
    i.order_id,
    i.order_item_id,
    cast(strftime(o.purchased_at, '%Y%m%d') as integer) as purchase_date_key,
    c.customer_unique_id      as customer_key,
    i.product_id              as product_key,
    i.seller_id               as seller_key,
    o.order_status,
    i.price,
    i.freight_value,
    i.price + i.freight_value as gross_value
from items i
join orders o using (order_id)
join customers c using (customer_id)
