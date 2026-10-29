-- Un cliente real puede tener varios customer_id (uno por orden): la clave es customer_unique_id.
with customers as (
    select * from {{ ref('stg_customers') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
),

joined as (
    select
        c.customer_unique_id,
        c.zip_prefix,
        c.city,
        c.state,
        o.purchased_at,
        row_number() over (partition by c.customer_unique_id order by o.purchased_at desc) as rn
    from customers c
    join orders o using (customer_id)
)

select
    customer_unique_id                      as customer_key,
    max(case when rn = 1 then city end)     as city,
    max(case when rn = 1 then state end)    as state,
    {{ state_region('max(case when rn = 1 then state end)') }} as region,
    min(purchased_at)                       as first_order_at,
    max(purchased_at)                       as last_order_at,
    count(*)                                as lifetime_orders
from joined
group by customer_unique_id
