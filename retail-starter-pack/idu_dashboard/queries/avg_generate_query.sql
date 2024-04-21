WITH T1 AS (
SELECT DISTINCT id_context, id_type,
'COALESCE((SELECT AVG(avg_id) FROM ${prefix}avg_min_max WHERE id_context = ''' || id_context || '''), 0.0) AS avg_' || id_context AS avg_logic
FROM ${prefix}ids_histogram_temp
)
SELECT ARRAY_JOIN(ARRAY_AGG(avg_logic), CONCAT(', ',chr(10))) as query_syntax FROM T1


