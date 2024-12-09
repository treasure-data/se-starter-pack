WITH TOP AS (
SELECT *, 
time as time_unixtime
FROM ${prefix}canonical_id_source_key_stats_top
)
,
SRC AS (
SELECT 
data_source as from_table, 
${td.last_results.approx_dist}
FROM ${user_master_id_table}
GROUP BY 1
)

SELECT 
time,
time_unixtime,
from_table,
total_distinct,
${td.last_results.distinct_cols}
FROM TOP

UNION ALL

SELECT 
(SELECT time from TOP) as time,
(SELECT time_unixtime FROM TOP) as time_unixtime,
from_table,
(SELECT total_distinct from TOP) as total_distinct,
${td.last_results.distinct_cols}
FROM SRC