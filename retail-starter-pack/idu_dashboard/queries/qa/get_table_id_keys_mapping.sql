with table_list as (
  select cast(json_parse('${tables}') AS ARRAY<JSON>) as yml_tbls,
    cast(json_parse('${keys}') AS ARRAY<JSON>) as yml_keys
),
yml_inputs as (
SELECT
  json_extract_scalar(yml_tbl, '$.database') as db_name,
  json_extract_scalar(yml_tbl, '$.table') as tbl_name,
  json_extract_scalar(key_columns_parsed, '$.column') AS column_name,
  json_extract_scalar(key_columns_parsed, '$.key') AS key_name
FROM table_list
CROSS JOIN UNNEST(yml_tbls) AS t(yml_tbl)
CROSS JOIN UNNEST(CAST(json_extract(yml_tbl,'$.key_columns')AS ARRAY<JSON>)) AS t(key_columns_parsed)
)
, yml_keys_input as (
  select
  json_extract_scalar(yml_key, '$.name') as key_name,
  cast(json_extract(yml_key, '$.invalid_texts') AS ARRAY<varchar>) as invalid_texts,
  json_extract_scalar(yml_key, '$.valid_regexp') as valid_regexp
  from table_list
  CROSS JOIN UNNEST(yml_keys) AS t(yml_key)
)
SELECT
  T2.table_id,
  'cdp_unification_${name}'||'.enriched_'||T1.tbl_name AS unification_table,
  T1.column_name as column_name_src,
  T3.key_type,
  T1.key_name as column_key,
  T4.invalid_texts,
  T4.valid_regexp
FROM yml_inputs T1
LEFT JOIN ${source_db}.${canonical_id_col}_tables T2 ON T1.tbl_name  = T2.table_name
LEFT JOIN ${source_db}.${canonical_id_col}_keys T3 ON T1.key_name = T3.key_name
LEFT JOIN yml_keys_input T4 on T1.key_name = T4.key_name