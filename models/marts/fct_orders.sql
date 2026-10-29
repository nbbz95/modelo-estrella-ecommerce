-- Grano: una orden. Junta montos, pago, logística y reseña.
with orders as (
    select * from {{ ref('stg_orders') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
),

items as (
    select
        order_id,
        count(*)            as items_count,
        count(distinct seller_id) as sellers_count,
        sum(price)          as items_value,
        sum(freight_value)  as freight_value
    from {{ ref('stg_order_items') }}
    group by order_id
),

payments as (
    select
        order_id,
        sum(payment_value) as payment_value,
        arg_max(payment_type, payment_value) as main_payment_type,
        max(installments)  as installments
    from {{ ref('stg_payments') }}
    group by order_id
),

reviews as (
    select order_id, review_score from {{ ref('stg_reviews') }}
)

select
    o.order_id,
    c.customer_unique_id                                   as customer_key,
    cast(strftime(o.purchased_at, '%Y%m%d') as integer)    as purchase_date_key,
    o.order_status,
    o.purchased_at,
    o.delivered_at,
    coalesce(i.items_count, 0)                             as items_count,
    coalesce(i.sellers_count, 0)                           as sellers_count,
    coalesce(i.items_value, 0)                             as items_value,
    coalesce(i.freight_value, 0)                           as freight_value,
    coalesce(i.items_value, 0) + coalesce(i.freight_value, 0) as gross_value,
    p.payment_value,
    p.main_payment_type,
    p.installments,
    date_diff('day', o.purchased_at, o.delivered_at)          as delivery_days,
    date_diff('day', o.estimated_delivery_at, o.delivered_at) as days_vs_estimate,
    case when o.delivered_at is null then null
         else o.delivered_at > o.estimated_delivery_at end   as is_late,
    r.review_score
from orders o
join customers c using (customer_id)
left join items i using (order_id)
left join payments p using (order_id)
left join reviews r using (order_id)
