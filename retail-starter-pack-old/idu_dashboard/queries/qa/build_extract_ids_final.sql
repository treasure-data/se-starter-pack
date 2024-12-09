with extracts as (
SELECT 
  unification_table,
  column_name,
  max_by(
    query_str,
    key_exists
  ) AS query_str
from
idu_qa_build_id_extracts  
GROUP BY
  unification_table,
  column_name
),

id_qry AS (
SELECT
  CONCAT('SELECT DISTINCT ${canonical_id_col} as over_merged_id, ${td.last_results.keys} from ( ', array_join(array_agg(qry_fraction), CONCAT(' ', chr(10), 'UNION ALL', chr(10)))) as qry
FROM
(
  select 
unification_table, 
CONCAT('select ${canonical_id_col},', array_join(array_agg(query_str order by column_name),','), ',''' ,unification_table , ''' as source_table from ', unification_table, ' where ${canonical_id_col} in (select over_merged_id from ${sink_database}.idu_qa_over_merged_canonical_ids)') as qry_fraction
from extracts group by 1
)
)

select CONCAT( qry, ' ) GROUP BY ${canonical_id_col}, ${td.last_results.keys}') as qry from id_qry