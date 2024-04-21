drop table if exists report_missing_src_columns;

create table if not exists report_missing_src_columns as
select *
from check_src_vs_ref_cols
where src_column_name is null
and ref_column_name is not null;


drop table if exists report_column_type_mismatches;

create table if not exists report_column_type_mismatches as
select *
from check_src_vs_ref_cols
where src_data_type != ref_data_type
and src_column_name is not null
and ref_column_name is not null
and src_table_name = ref_table_name;

drop table if exists report_extra_columns_in_src;

create table if not exists report_extra_columns_in_src as
select *
from check_src_vs_ref_cols
where ref_column_name is null;

drop table if exists report_missing_tables_in_src;

create table if not exists report_missing_tables_in_src as
select *
from check_src_vs_ref_tables
where src_table_name is null;

drop table if exists report_extra_tables_in_src;

create table if not exists report_extra_tables_in_src as
select *
from check_src_vs_ref_tables
where ref_table_name is null;

drop table if exists report_deviation;

create table if not exists report_deviation as
with deviation as (
  select 'extra_tables' as type, 'warning' as issue, count(1) as cnt from report_extra_tables_in_src
  union all
  select 'extra_columns' as type, 'warning' as issue, count(1) as cnt from report_extra_columns_in_src
  union all
  select 'missing_columns' as type, 'error' as issue, count(1) as cnt from report_missing_src_columns
  union all
  select 'mismatch_column_type' as type, 'error' as issue, count(1) as cnt from report_column_type_mismatches
  union all
  select 'missing_tables' as type, 'error' as issue, count(1) as cnt from report_missing_tables_in_src
)
select * from deviation;
