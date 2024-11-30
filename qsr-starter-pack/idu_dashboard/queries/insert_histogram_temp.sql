  SELECT  split(histogram_${td.each.key_name},',') AS hist , '${td.each.key_name}' AS distinct_id, '${td.each.id_context}' AS id_context, '${td.each.id_type}' AS id_type
  FROM    ${source_db}.${canonical_id_col}_result_key_stats
  WHERE   1=1
  AND     from_table = '*'
  AND     time = (SELECT MAX(time) FROM ${source_db}.${canonical_id_col}_result_key_stats)