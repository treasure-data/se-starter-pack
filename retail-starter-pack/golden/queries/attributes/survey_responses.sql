with survey_response_cte as (
  select 
    mavi_id, 
    submitted_at, 
    answer_numeric,
    answer
  from survey_responses
)

  SELECT
    ${unification_id},
    COUNT(*) AS survey_response_count,
    CAST(MAX(CAST(submitted_at AS TIMESTAMP)) as varchar) AS last_survey_response_date,
    TD_TIME_PARSE(CAST(MAX(CAST(submitted_at AS TIMESTAMP)) as varchar)) as last_survey_response_date_unix,
    AVG(CAST(answer_numeric AS DOUBLE)) AS avg_survey_score,
    MAX_BY(answer_numeric, submitted_at) AS last_survey_score,
    MAX_BY(answer, submitted_at) AS last_survey_answer
  FROM survey_responses
  GROUP BY ${unification_id}
