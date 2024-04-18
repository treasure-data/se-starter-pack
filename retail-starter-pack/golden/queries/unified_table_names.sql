select table_name
from information_schema.tables
where table_schema = '${database}'
and (
       table_name not like '%_id_graph'
    or table_name not like '%_id_keys'
    or table_name not like '%_id_lookup'
    or table_name not like '%_id_result_key_stats'
    or table_name not like '%_id_source_key_stats'
    or table_name not like '%_id_tables'
    )