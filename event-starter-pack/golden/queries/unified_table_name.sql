select table_name
from information_schema.tables
where table_schema = '${database}'
and (
        table_name not like '%_id_graph%'
    and table_name not like '%_id_keys%'
    and table_name not like '%_id_lookup%'
    and table_name not like '%_id_result_key_stats%'
    and table_name not like '%_id_source_key_stats%'
    and table_name not like '%_id_tables%'
    );
