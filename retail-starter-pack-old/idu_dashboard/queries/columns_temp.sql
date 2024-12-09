WITH T0 AS (
  SELECT 
  TRANSFORM((SELECT ARRAY_AGG(key_name) FROM ${prefix}column_mapping WHERE addressable = 1), x -> 'distinct_'||x) as addressable_ids_array,
  TRANSFORM((SELECT ARRAY_AGG(key_name) FROM ${prefix}column_mapping WHERE addressable = 0), x -> 'distinct_'||x) as non_addressable_ids_array,
  TRANSFORM((SELECT ARRAY_AGG(key_name) FROM ${prefix}column_mapping WHERE known = 1), x -> 'distinct_'||x) as known_ids_array,
  TRANSFORM((SELECT ARRAY_AGG(key_name) FROM ${prefix}column_mapping WHERE known = 0), x -> 'distinct_'||x) as unknown_ids_array,
  TRANSFORM((SELECT ARRAY_AGG(key_name) FROM ${prefix}column_mapping WHERE id_type = 'composite'), x -> 'distinct_'||x) as composite_ids_array
)
,T1 AS (
  SELECT ARRAY_AGG(c.column_name) as all_id_cols
  FROM information_schema.columns c
  CROSS JOIN T0
  WHERE c.table_schema = '${reporting_db}'
    AND c.table_name = '${source_tbl}'
    AND c.column_name NOT IN ('from_table','total_distinct','time')
)

SELECT T1.all_id_cols,
  T0.addressable_ids_array as addressable_cols,
  T0.non_addressable_ids_array as non_addressable_cols,
  T0.known_ids_array as known_ids_cols,
  T0.unknown_ids_array as unknown_ids_cols,
  T0.composite_ids_array as composite_ids_cols,
  IF(T0.addressable_ids_array IS NULL, 'CAST(0 AS INTEGER)', ARRAY_JOIN(TRANSFORM(T0.addressable_ids_array, x -> 'COALESCE('||x||',0)'),'+')) as sum_addressable,
  IF(T0.non_addressable_ids_array IS NULL, 'CAST(0 AS INTEGER)', ARRAY_JOIN(TRANSFORM(T0.non_addressable_ids_array, x -> 'COALESCE('||x||',0)'),'+')) as sum_non_addressable,
  IF(T0.known_ids_array IS NULL, 'CAST(0 AS INTEGER)', ARRAY_JOIN(TRANSFORM(T0.known_ids_array, x -> 'COALESCE('||x||',0)'),'+'))as sum_known,
  IF(T0.unknown_ids_array IS NULL, 'CAST(0 AS INTEGER)', ARRAY_JOIN(TRANSFORM(T0.unknown_ids_array, x -> 'COALESCE('||x||',0)'),'+')) as sum_unknown,
  IF(T0.composite_ids_array IS NULL, 'CAST(0 AS INTEGER)', ARRAY_JOIN(TRANSFORM(T0.composite_ids_array, x -> 'COALESCE('||x||',0)'),'+')) as sum_composite
FROM T1
CROSS JOIN T0
