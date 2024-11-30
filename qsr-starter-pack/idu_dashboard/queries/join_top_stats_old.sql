WITH T1 AS (
  SELECT * FROM ${source_db}.${canonical_id_col}_source_key_stats
  WHERE time = (SELECT MAX(time) FROM ${source_db}.${canonical_id_col}_source_key_stats)
)
SELECT from_table,
REPLACE('${td.each.column_name}', 'distinct_', '') as id_name,
${td.each.column_name} AS distinct_cnt
FROM T1