with keys as (select key_type, key_name
from ${src_database}.${unification_id}_keys
where key_name in ('email', 'phone_number')
),
table_ids as (select key_name, id_key_type, id_source_table_ids
from ${src_database}.${unification_id}_lookup a join keys b
on (a.id_key_type = b.key_type)
),
table_nm as (SELECT distinct
    key_name,
    -- id_key_type, id_source_table_ids,
    value AS table_id
FROM table_ids
CROSS JOIN UNNEST(id_source_table_ids) AS t(value)
)
select key_name, table_name
from table_nm a join ${src_database}.${unification_id}_tables b
on (a.table_id = b.table_id)
order by key_name
;