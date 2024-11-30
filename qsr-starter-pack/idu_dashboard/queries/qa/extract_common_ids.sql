SELECT  
  over_merged_id, 
  '${key['name']}' as id_type,
  ${key['name']} as id,
  COUNT(*) AS total_sets,
  ${td.last_results.agg_qry}
FROM
  ${sink_database}.idu_qa_over_merged_id_sets
WHERE
  ${key['name']} IS NOT NULL
GROUP BY
  1, 2, 3