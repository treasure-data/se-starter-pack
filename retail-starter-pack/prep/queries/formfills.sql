DROP TABLE IF EXISTS ${prp}_${sub}.formfills;

CREATE TABLE ${prp}_${sub}.formfills

select * from ${raw}_${sub}.formfills
