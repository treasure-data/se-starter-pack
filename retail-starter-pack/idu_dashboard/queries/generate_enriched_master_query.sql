SELECT ARRAY_JOIN(ARRAY_AGG(source_table_id), CONCAT(', ',chr(10))) as distinct_cols, 
ARRAY_JOIN(ARRAY_AGG(CONCAT('APPROX_DISTINCT(', key_name, ') AS distinct_', key_name)), CONCAT(', ',chr(10))) as approx_dist
FROM ${prefix}column_mapping