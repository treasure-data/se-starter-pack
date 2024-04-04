
SELECT  col_name, 'custom' as type
FROM ${prefix}columns_temp
CROSS JOIN UNNEST (custom_cols) as t (col_name)

UNION ALL 
SELECT col_name, 'addressable' as type
FROM ${prefix}columns_temp
CROSS JOIN UNNEST (addressable_cols) as t (col_name)
