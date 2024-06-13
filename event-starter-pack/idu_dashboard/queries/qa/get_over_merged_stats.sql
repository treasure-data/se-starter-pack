WITH T0 AS (
  SELECT canonical_id, id_key_type, id FROM ${id_lookup_table}
  WHERE canonical_id IN (SELECT over_merged_id FROM idu_qa_over_merged_canonical_ids)
),
T1 AS (
SELECT canonical_id, id_key_type, APPROX_DISTINCT(id) AS id_cnt 
FROM  T0
GROUP BY 1, 2
ORDER by 3 desc
),
BASE AS (
SELECT  
T1.id_key_type,
T2.key_name,
min(T1.id_cnt) AS min_id, 
APPROX_PERCENTILE(T1.id_cnt, 0.25) AS q1, 
APPROX_PERCENTILE(T1.id_cnt, 0.5) AS median_id, 
ROUND(AVG(T1.id_cnt), 3) AS avg_id, 
APPROX_PERCENTILE(T1.id_cnt, 0.75) AS q3, 
MAX(T1.id_cnt) AS max_id, 
ROUND(STDDEV(T1.id_cnt), 3) AS stddev_id,
ROUND(skewness(T1.id_cnt), 3) AS skew_id,
ROUND(STDDEV(T1.id_cnt)*1.0 / AVG(T1.id_cnt), 3) as cv_ratio
FROM T1
JOIN ${source_db}.${canonical_id_col}_keys T2
ON T1.id_key_type = T2.key_type
GROUP BY 1, 2
)
SELECT BASE.*,
CEILING(BASE.avg_id + 2.5*BASE.cv_ratio) AS over_merge_limit_cv,
CEILING(BASE.avg_id + 2.5*BASE.stddev_id) AS over_merge_limit_stdev,
T2.id_context, T2.known, T2.addressable, T2.id_type
FROM BASE
LEFT JOIN idu_column_mapping T2
ON BASE.id_key_type = T2.key_type