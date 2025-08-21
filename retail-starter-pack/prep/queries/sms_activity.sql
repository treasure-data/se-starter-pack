DROP TABLE IF EXISTS ${prp}_${sub}.sms_activity;

CREATE TABLE ${prp}_${sub}.sms_activity

select * from ${raw}_${sub}.sms_activity
