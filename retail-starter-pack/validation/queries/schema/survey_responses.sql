DROP TABLE IF EXISTS survey_responses_tmp;
CREATE TABLE survey_responses_tmp (
    survey_id VARCHAR,
    respondent_id VARCHAR,
    question_id VARCHAR,
    question_text VARCHAR,
    answer VARCHAR,
    answer_numeric DOUBLE,
    submitted_at VARCHAR,
    customer_id VARCHAR,
    email VARCHAR,
    phone_number VARCHAR,
    time BIGINT
);