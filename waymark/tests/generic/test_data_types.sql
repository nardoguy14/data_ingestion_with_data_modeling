{% test data_type(model, column_name, desired, table_name) %}

SELECT
    DATA_TYPE
FROM
    INFORMATION_SCHEMA.COLUMNS
WHERE
    (TABLE_NAME = '{{table_name}}' AND
    COLUMN_NAME = '{{column_name}}' AND
    DATA_TYPE != '{{desired}}')

{% endtest %}