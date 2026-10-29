{# Región de Brasil a partir de la sigla del estado. #}
{% macro state_region(col) -%}
    case
        when {{ col }} in ('SP', 'RJ', 'MG', 'ES') then 'Southeast'
        when {{ col }} in ('PR', 'SC', 'RS') then 'South'
        when {{ col }} in ('DF', 'GO', 'MT', 'MS') then 'Center-West'
        when {{ col }} in ('BA', 'SE', 'AL', 'PE', 'PB', 'RN', 'CE', 'PI', 'MA') then 'Northeast'
        when {{ col }} in ('AM', 'RR', 'AP', 'PA', 'TO', 'RO', 'AC') then 'North'
        else 'Unknown'
    end
{%- endmacro %}
