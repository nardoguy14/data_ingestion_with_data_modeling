
{% test unique_two_fields(model, column_name, column_name2) %}

SELECT {{column_name}}, {{column_name2}}
FROM {{model}}
GROUP BY  {{column_name}}, {{column_name2}}
HAVING COUNT(*) > 1

{% endtest %}