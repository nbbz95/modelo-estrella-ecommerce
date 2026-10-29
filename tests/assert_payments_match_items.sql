-- En órdenes entregadas, lo pagado debe coincidir con productos + flete (tolerancia de 1 BRL).
-- Se admite hasta un 1% de excepciones (vouchers y redondeos de cuotas).
with diffs as (
    select abs(payment_value - gross_value) > 1 as mismatch
    from {{ ref('fct_orders') }}
    where order_status = 'delivered' and payment_value is not null
)
select sum(case when mismatch then 1 else 0 end) * 1.0 / count(*) as mismatch_rate
from diffs
having sum(case when mismatch then 1 else 0 end) * 1.0 / count(*) > 0.01
