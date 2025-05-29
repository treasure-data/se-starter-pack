-- Derived attributes from survey_responses
-- Aggregated by normalized email and phone number

CREATE OR REPLACE TABLE ${anl}_${sub}.survey_derived_attributes AS
WITH 
base_1 AS (
  SELECT DISTINCT ${unification_id} 
  FROM parent_table
),

survey_agg AS (
  SELECT
    ${unification_id},
    COUNT(*) AS survey_response_count,
    MAX(CAST(submitted_at AS TIMESTAMP)) AS last_survey_response_date,
    AVG(CAST(answer_numeric AS DOUBLE)) AS avg_survey_score,
    MAX_BY(answer_numeric, submitted_at) AS last_survey_score,
    MAX_BY(answer, submitted_at) AS last_survey_answer
  FROM ${stg}_${sub}.survey_responses
  GROUP BY ${unification_id}
)

SELECT 
  base_1.${unification_id},
  COALESCE(survey_agg.survey_response_count, 0) AS survey_response_count,
  survey_agg.last_survey_response_date,
  survey_agg.avg_survey_score,
  survey_agg.last_survey_score,
  survey_agg.last_survey_answer
FROM base_1
LEFT JOIN survey_agg ON base_1.${unification_id} = survey_agg.${unification_id};