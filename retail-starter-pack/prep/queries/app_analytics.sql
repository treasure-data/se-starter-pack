DROP TABLE IF EXISTS ${prp}_${sub}.app_analytics;

CREATE TABLE ${prp}_${sub}.app_analytics

select * from ${raw}_${sub}.app_analytics
