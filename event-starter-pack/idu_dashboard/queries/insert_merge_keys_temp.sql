SELECT SUBSTR(CAST(FROM_UNIXTIME(r.time) AS VARCHAR),1,10)AS datetime , r.time as time_unixtime, 'diff_${td.each.distinct_id}' AS key , s.distinct_${td.each.distinct_id} - r.distinct_with_${td.each.distinct_id} AS value
FROM  ${reporting_db}.${prefix}canonical_id_result_key_stats_top r
,     ${reporting_db}.${prefix}canonical_id_source_key_stats_top s