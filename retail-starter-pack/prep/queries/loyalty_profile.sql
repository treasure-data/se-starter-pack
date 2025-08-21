DROP TABLE IF EXISTS ${prp}_${sub}.${tbl.src_table_name};

CREATE TABLE ${prp}_${sub}.${tbl.src_table_name}

select * from ${raw}_${sub}.${tbl.src_table_name}
