with products as (
    select * from {{ read_raw('olist_products_dataset') }}
),

translation as (
    select * from {{ read_raw('product_category_name_translation') }}
)

select
    p.product_id,
    coalesce(t.product_category_name_english, p.product_category_name, 'unknown') as category,
    p.product_photos_qty  as photos_qty,
    p.product_weight_g    as weight_g,
    p.product_length_cm * p.product_height_cm * p.product_width_cm as volume_cm3
from products p
left join translation t using (product_category_name)
