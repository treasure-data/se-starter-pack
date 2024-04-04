WITH KNOW AS (
  SELECT COUNT(DISTINCT canonical_id) as cnt_known
FROM ${source_db}.${canonical_id_col}_lookup
WHERE id_key_type IN (SELECT DISTINCT key_type FROM idu_column_mapping WHERE known = 1 )
), 

ADDRESSABLE AS (
    SELECT COUNT(DISTINCT canonical_id) as cnt_addressable
FROM ${source_db}.${canonical_id_col}_lookup
WHERE id_key_type IN (SELECT DISTINCT key_type FROM idu_column_mapping WHERE addressable = 1 )
),

 
EMAIL AS (
    SELECT COUNT(DISTINCT canonical_id) as cnt_email
FROM ${source_db}.${canonical_id_col}_lookup
WHERE id_key_type IN (SELECT DISTINCT key_type FROM idu_column_mapping WHERE id_context = 'email' )
),

PHONE AS (
    SELECT COUNT(DISTINCT canonical_id) as cnt_phone
FROM ${source_db}.${canonical_id_col}_lookup
WHERE id_key_type IN (SELECT DISTINCT key_type FROM idu_column_mapping WHERE id_context = 'phone' )
),

EVERYONE AS (
SELECT COUNT(DISTINCT canonical_id) as total_profiles FROM ${source_db}.${canonical_id_col}_lookup
)

SELECT 
'known/unknown' as metric_type,
'known' as col_value,
cnt_known as cnt
FROM KNOW

UNION ALL 

SELECT
'known/unknown' as metric_type,
'unknown' as col_value, 
(SELECT total_profiles FROM EVERYONE) - cnt_known as cnt
FROM KNOW

UNION ALL 

SELECT 
'addressable or not' as metric_type,
'addressable' as col_value, 
cnt_addressable as cnt
FROM ADDRESSABLE

UNION ALL 

SELECT 
'addressable or not' as metric_type,
'non-addressable' as col_value, 
(SELECT total_profiles FROM EVERYONE) - cnt_addressable as cnt
FROM ADDRESSABLE

UNION ALL 

SELECT 
'has email or not' as metric_type,
'has email' as col_value, 
cnt_email as cnt
FROM EMAIL

UNION ALL 

SELECT 
'has email or not' as metric_type,
'no email' as col_value, 
(SELECT total_profiles FROM EVERYONE) - cnt_email as cnt
FROM EMAIL

UNION ALL 

SELECT 
'has phone or not' as metric_type,
'has phone' as col_value, 
cnt_phone as cnt
FROM PHONE

UNION ALL 

SELECT 
'has phone or not' as metric_type,
'no phone' as col_value, 
(SELECT total_profiles FROM EVERYONE) - cnt_phone as cnt
FROM PHONE