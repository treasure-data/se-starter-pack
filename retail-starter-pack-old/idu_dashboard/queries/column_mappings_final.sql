WITH T1 AS (
  SELECT DISTINCT key_type,  key_name, CONCAT('distinct_', key_name) as source_table_id FROM ${source_db}.${canonical_id_col}_keys
  WHERE key_name IN (SELECT DISTINCT col_name FROM ${prefix}col_mapping_temp)
),
T3 AS (
SELECT T1.*,
COALESCE(T2.id_context, 'custom') as id_context,
COALESCE(T2.known, 0) as known,
COALESCE(T2.addressable, 0) as addressable
FROM T1
LEFT JOIN ${prefix}col_mapping_temp T2
ON T1.key_name = T2.col_name
)
SELECT T3.*,
COALESCE(IF((known = 1 and addressable = 1), 'known-addressable', NULL), IF((known = 0 and addressable = 1), 'unknown-addressable', IF(id_context = 'composite', id_context, 'non-addressable'))) as id_type
FROM T3