SELECT column_name FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = '${source_db}' AND table_name = '${canonical_id_col}_source_key_stats'
AND REGEXP_LIKE(column_name, 'distinct_')