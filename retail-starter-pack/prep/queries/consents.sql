DROP TABLE IF EXISTS ${prp}_${sub}.consents;

CREATE TABLE ${prp}_${sub}.consents

select * from ${raw}_${sub}.consents
