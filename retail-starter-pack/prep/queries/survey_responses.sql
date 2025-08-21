DROP TABLE IF EXISTS ${prp}_${sub}.survey_responses;

CREATE TABLE ${prp}_${sub}.survey_responses

select * from ${raw}_${sub}.survey_responses
