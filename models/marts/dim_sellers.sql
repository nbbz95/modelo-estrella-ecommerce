select
    seller_id                   as seller_key,
    city,
    state,
    {{ state_region('state') }} as region
from {{ ref('stg_sellers') }}
