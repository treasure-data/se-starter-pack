WITH 
column_values AS (
    SELECT DISTINCT column_key as column_name
    FROM idu_qa_src_tables_id_keys_mapping
)
,
unification_values AS (
    SELECT DISTINCT table_id, unification_table
    FROM idu_qa_src_tables_id_keys_mapping
)
,
CJ AS (
    SELECT  uv.table_id, uv.unification_table, cv.column_name
    FROM column_values cv
    CROSS JOIN unification_values uv
)
SELECT
    BASE.key_type,
    BASE.column_name_src,
    COALESCE(BASE.column_name_src || ' AS ' || CJ.column_name, 'CAST(NULL AS VARCHAR) AS ' || CJ.column_name) AS query_str,
    CJ.table_id,
    CJ.unification_table,
    CJ.column_name,
    CASE 
    WHEN BASE.key_type IS NOT NULL THEN 1 ELSE 0 END AS key_exists
    FROM CJ
    LEFT JOIN idu_qa_src_tables_id_keys_mapping BASE
    ON CJ.table_id = BASE.table_id AND CJ.column_name = BASE.column_key