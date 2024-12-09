WITH T1 AS (
SELECT id_key_type, key_name, id_context, known as known_flag, avg_id, stddev_id, over_merge_limit_cv, CONCAT('WHERE id_key_type = ', CAST(id_key_type AS VARCHAR)) as filter_syntax
FROM idu_qa_avg_id_stats
WHERE time = (SELECT MAX(time) FROM idu_qa_avg_id_stats)
)
SELECT known_flag, CEILING(AVG(over_merge_limit_cv)) as over_merge_limit_cv, 
'WHERE id_key_type IN (' || ARRAY_JOIN(ARRAY_AGG(CAST(id_key_type AS VARCHAR)), ', ') || ')' as filter_syntax
FROM T1
GROUP BY 1