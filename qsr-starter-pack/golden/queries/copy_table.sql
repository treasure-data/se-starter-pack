drop table if exists ${td.each.table_name};

create table if not exists ${td.each.table_name} as
select * from ${src_database}.${td.each.table_name};