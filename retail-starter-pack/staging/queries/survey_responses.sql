drop table if exists ${stg}_${sub}.${tbl};

create table ${stg}_${sub}.${tbl} as

SELECT
  *,
  -- Validate email format
  cast(COALESCE(regexp_like("email", '^(?=.{1,256})(?=.{1,64}@.{1,255}$)[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$'), false) as varchar) AS "valid_email_flag",
  -- Normalize email
  case
    when nullif(lower(ltrim(rtrim("email"))), 'null') is null then null
    when nullif(lower(ltrim(rtrim("email"))), '') is null then null
    else lower(ltrim(rtrim(regexp_replace("email", '[^a-zA-Z0-9.@_+-]', ''))))
  end AS "trfmd_email",
  -- Normalize phone number
  case
    when nullif(lower(ltrim(rtrim("phone_number"))), 'null') is null then null
    when nullif(lower(ltrim(rtrim("phone_number"))), '') is null then null
    else ARRAY_JOIN(REGEXP_EXTRACT_ALL(replace(lower(ltrim(rtrim("phone_number"))), ' ', ''), '([0-9]+)?'), '')
  end AS "trfmd_phone_number"
FROM
  survey_responses;