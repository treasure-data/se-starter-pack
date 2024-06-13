SELECT canonical_id AS over_merged_id, count(*) as count_raw_ids from ${id_lookup_table}
${td.last_results.filter_syntax}
GROUP BY 1 
HAVING count(*) >= ${td.last_results.merged_ids_limit}