{# Usa el schema tal cual (staging / main) en vez de concatenarlo con el del perfil. #}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {{ custom_schema_name if custom_schema_name else target.schema }}
{%- endmacro %}
