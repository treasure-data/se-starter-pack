DROP TABLE IF EXISTS ${prp}_${sub}.pageviews;

CREATE TABLE ${prp}_${sub}.pageviews

select * from ${raw}_${sub}.pageviews
