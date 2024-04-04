WITH prep AS (
    SELECT  DISTINCT SUBSTR(cast(FROM_UNIXTIME(a.time) AS VARCHAR),1,10) AS datetime
        ,MAX(a.total_distinct) AS unified_profiles
        ,max(b.total_distinct) AS pre_unification_profiles
    FROM    ${source_db}.${canonical_id_col}_result_key_stats a 
    JOIN    ${source_db}.${canonical_id_col}_source_key_stats b ON a.time = b.time
    WHERE a.from_table = '*'
    GROUP BY a.time
)

SELECT *, 
ROUND(((p.pre_unification_profiles-p.unified_profiles)*100.0)/p.pre_unification_profiles, 5) as ratio,
${session_id} as session_id,
CAST(to_unixtime(CAST(datetime AS TIMESTAMP)) AS INTEGER) as unixtime_tstamp
FROM prep p
ORDER BY datetime DESC