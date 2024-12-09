drop table if exists ${tbl};

create table if not exists ${tbl} as
select * from ${src_database}.enriched_${tbl}; 