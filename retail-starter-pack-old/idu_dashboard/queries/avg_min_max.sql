WITH T1 AS (
SELECT canonical_id, id_key_type, APPROX_DISTINCT(id) AS id_cnt 
FROM  ${id_lookup_table}
GROUP BY 1, 2
ORDER by 3 desc
),
BASE AS (
SELECT  
T2.key_name,
T2.id_context,
T2.id_type,
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
JOIN ${reporting_db}.${prefix}column_mapping T2
ON T1.id_key_type = T2.key_type
GROUP BY 1, 2, 3
)
SELECT BASE.*,
CAST((BASE.q3 - BASE.q1) AS DOUBLE) AS iqr_range,
CEILING(BASE.avg_id + 2.5*BASE.stddev_id) AS over_merge_limit_stdev,
CEILING(BASE.avg_id + 2.5*BASE.cv_ratio) AS over_merge_limit_cv,
BASE.q3 + 1.5*(BASE.q3 - BASE.q1) AS over_merge_limit_iqr
FROM BASE


----OLD QUERY
-- SELECT  MAX(CAST(num_times AS int)) AS max_id , MIN(cast(num_times AS int))AS min_id 
--     ,ROUND(SUM(CAST(num_times AS int)*ids*1.0)/SUM(ids), 2) as avg_id
--     ,id_context
--     ,id_type
-- FROM    ${reporting_db}.${prefix}ids_histogram
-- GROUP BY id_context, id_type