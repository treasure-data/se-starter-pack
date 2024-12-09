select array_join(array_agg(qry_fraction), ', ') as agg_qry
from (
select CONCAT('array_agg(DISTINCT ', column_name, ') as ', column_name, '_array, count(DISTINCT ', column_name, ') as ', column_name, '_count') as qry_fraction
from INFORMATION_SCHEMA.columns where table_name = 'idu_qa_over_merged_id_sets' and table_schema = '${sink_database}'
and column_name not in ('${canonical_id_col}','over_merged_id', 'source_table', 'time')
)