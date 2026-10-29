-- Hay órdenes con más de una reseña: se queda la última respondida.
select
    review_id,
    order_id,
    review_score,
    cast(review_creation_date as timestamp) as created_at
from {{ read_raw('olist_order_reviews_dataset') }}
qualify row_number() over (partition by order_id order by review_answer_timestamp desc, review_id) = 1
