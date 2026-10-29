select
    product_id                         as product_key,
    category,
    photos_qty,
    weight_g,
    volume_cm3,
    case
        when weight_g is null then 'unknown'
        when weight_g < 500 then 'small (<0.5 kg)'
        when weight_g < 5000 then 'medium (0.5-5 kg)'
        else 'large (>5 kg)'
    end as size_band
from {{ ref('stg_products') }}
