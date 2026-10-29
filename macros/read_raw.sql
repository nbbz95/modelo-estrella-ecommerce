{# Lee un CSV crudo de Olist desde la carpeta data/. #}
{% macro read_raw(name) -%}
    read_csv('{{ var("data_path") }}/{{ name }}.csv', header = true, auto_detect = true)
{%- endmacro %}
