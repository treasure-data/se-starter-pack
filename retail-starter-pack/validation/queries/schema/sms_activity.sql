DROP TABLE IF EXISTS sms_activity_tmp;
CREATE TABLE sms_activity_tmp(
    time BIGINT,
    phone_number VARCHAR,
    email VARCHAR,
    activity_type VARCHAR,
    message_type VARCHAR,
    message_name VARCHAR,
    message_text VARCHAR,
    message_link VARCHAR,
    message_creative VARCHAR,
    message_date BIGINT
);



