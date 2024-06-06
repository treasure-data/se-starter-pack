drop table if exists check_src_vs_ref_cols;

create table if not exists check_src_vs_ref_cols as
with src_meta as (select table_name as src_table_name, column_name as src_column_name, data_type as src_data_type
from INFORMATION_SCHEMA.COLUMNS
where  table_schema = '${src}_${sub}'),

ref_meta as (select replace(table_name, '_tmp', '') ref_table_name, column_name as ref_column_name, data_type as ref_data_type
from INFORMATION_SCHEMA.COLUMNS
where  table_schema = 'va_config_${sub}'
and table_name like '%_tmp')

select src_meta.*, ref_meta.*
from
src_meta  full outer join ref_meta
on (src_meta.src_table_name = ref_meta.ref_table_name
and src_meta.src_column_name = ref_meta.ref_column_name)
order by src_meta.src_table_name, ref_meta.ref_table_name;

drop table if exists check_src_vs_ref_tables;

create table if not exists check_src_vs_ref_tables as
with src_meta as (select table_name as src_table_name
from INFORMATION_SCHEMA.TABLES
where  table_schema = '${src}_${sub}'),

ref_meta as (select replace(table_name, '_tmp', '') ref_table_name
from INFORMATION_SCHEMA.TABLES
where  table_schema = 'va_config_${sub}'
and table_name like '%_tmp')

select src_meta.*, ref_meta.*
from src_meta  full outer join ref_meta
on (src_meta.src_table_name = ref_meta.ref_table_name)
order by src_meta.src_table_name, ref_meta.ref_table_name;