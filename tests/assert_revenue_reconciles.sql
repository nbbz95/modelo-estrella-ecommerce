-- El total del hecho a nivel línea y el del hecho a nivel orden tienen que ser iguales.
select a.total as items_total, b.total as orders_total
from (select sum(gross_value) as total from {{ ref('fct_order_items') }}) a
cross join (select sum(gross_value) as total from {{ ref('fct_orders') }}) b
where abs(a.total - b.total) > 0.01
