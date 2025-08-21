DROP TABLE IF EXISTS ${prp}_${sub}.email_activity;

CREATE TABLE ${prp}_${sub}.email_activity

select * from ${raw}_${sub}.email_activity
