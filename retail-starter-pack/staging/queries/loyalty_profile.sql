drop table if exists ${stg}_${sub}.${tbl}; 

create table ${stg}_${sub}.${tbl} as 

SELECT
*,
TD_TIME_PARSE(updated_at) as trfmd_updated_at_unix,
TD_TIME_PARSE(created_at) as trfmd_created_at_unix,
TD_TIME_PARSE(current_membership_level_expiration) as trfmd_current_membership_level_expiration_unix,
--
case
  when nullif(lower(ltrim(rtrim("country"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("country"))), '') is null then null
  else array_join((transform((split(lower(trim("country")),' ')), x -> concat(upper(substr(x,1,1)),substr(x,2,length(x))))),' ','')
end   AS  "trfmd_country",
--
array_join((transform((split(lower(trim(concat(first_name,' ',last_name))),' ')), x -> concat(upper(substr(x,1,1)),substr(x,2,length(x))))),' ','')  AS  "trfmd_full_name",
--
case
  when nullif(lower(ltrim(rtrim("state"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("state"))), '') is null then null
  else array_join((transform((split(lower(trim("state")),' ')), x -> concat(upper(substr(x,1,1)),substr(x,2,length(x))))),' ','')
end   AS  "trfmd_state",
--
case
  when nullif(lower(ltrim(rtrim("date_of_birth"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("date_of_birth"))), '') is null then null
  else lower(ltrim(rtrim("date_of_birth")))
end   AS  "trfmd_date_of_birth",
--
TD_TIME_PARSE(date_of_birth) as  "trfmd_date_of_birth_unix",
--
case
  when nullif(lower(ltrim(rtrim("phone_number"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("phone_number"))), '') is null then null
  else ARRAY_JOIN(REGEXP_EXTRACT_ALL(replace(lower(ltrim(rtrim("phone_number"))), ' ', ''), '([0-9]+)?'), '')
  end   AS  "trfmd_phone_number",
--
case
  when nullif(lower(ltrim(rtrim("first_name"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("first_name"))), '') is null then null
  else array_join((transform((split(lower(trim("first_name")),' ')), x -> concat(upper(substr(x,1,1)),substr(x,2,length(x))))),' ','')
end   AS  "trfmd_first_name",
--
case
  when nullif(lower(ltrim(rtrim("last_name"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("last_name"))), '') is null then null
  else array_join((transform((split(lower(trim("last_name")),' ')), x -> concat(upper(substr(x,1,1)),substr(x,2,length(x))))),' ','')
end   AS  "trfmd_last_name",
--
cast(COALESCE(regexp_like( "email", '^(?=.{1,256})(?=.{1,64}@.{1,255}$)[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$'), false) as varchar)  AS  "valid_email_flag",
--
case
  when nullif(lower(ltrim(rtrim("membership_tier"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("membership_tier"))), '') is null then null
  else array_join((transform((split(lower(trim("membership_tier")),' ')), x -> concat(upper(substr(x,1,1)),substr(x,2,length(x))))),' ','')
end   AS  "trfmd_membership_tier",
--
case
  when nullif(lower(ltrim(rtrim("membership_status"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("membership_status"))), '') is null then null
  else array_join((transform((split(lower(trim("membership_status")),' ')), x -> concat(upper(substr(x,1,1)),substr(x,2,length(x))))),' ','')
end   AS  "trfmd_membership_status",
--
case
  when nullif(lower(ltrim(rtrim("postal_code"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("postal_code"))), '') is null then null
  else lower(ltrim(rtrim("postal_code")))
end   AS  "trfmd_postal_code",
--
case
  when nullif(lower(ltrim(rtrim("address"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("address"))), '') is null then null
  else array_join((transform((split(lower(trim("address")),' ')), x -> concat(upper(substr(x,1,1)),substr(x,2,length(x))))),' ','')
end   AS  "trfmd_address",
--
case
  when lower(ltrim(rtrim("gender"))) = 'female' then 'Female'
  when lower(ltrim(rtrim("gender"))) = 'male' then 'Male'
  else lower(ltrim(rtrim("gender"))) end
  AS  "trfmd_gender",
--
case
  when nullif(lower(ltrim(rtrim("city"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("city"))), '') is null then null
  else array_join((transform((split(lower(trim("city")),' ')), x -> concat(upper(substr(x,1,1)),substr(x,2,length(x))))),' ','')
end   AS  "trfmd_city",
--
date_diff(
  'year',
  coalesce(
    try(date_parse(date_of_birth, '%Y-%m-%d %H:%i:%s.%f')),  -- Full datetime with milliseconds
    try(date_parse(date_of_birth, '%Y-%m-%d %H:%i:%s')),     -- Full datetime without milliseconds
    try(date_parse(date_of_birth, '%Y-%m-%d')),              -- Date only (no time)
    try(date_parse(date_of_birth, '%m/%d/%Y %H:%i:%s.%f')),  -- MM/DD/YYYY format with milliseconds
    try(date_parse(date_of_birth, '%m/%d/%Y %H:%i:%s')),     -- MM/DD/YYYY format without milliseconds
    try(date_parse(date_of_birth, '%m/%d/%Y'))               -- MM/DD/YYYY format (no time)
  ), current_date
  )  AS  "trfmd_age",
--
case
  when nullif(lower(ltrim(rtrim("email"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("email"))), '') is null then null
  when nullif(lower(trim("email")), '') in (select lower(trim(invalid_email)) from ${stg}_${sub}.invalid_emails ) then null
  else lower(ltrim(rtrim(regexp_replace("email", '[^a-zA-Z0-9.@_+-]', ''))))
end   AS  "trfmd_email",
--
case
  when nullif(lower(ltrim(rtrim("secondary_email"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("secondary_email"))), '') is null then null
  else lower(ltrim(rtrim(regexp_replace("secondary_email", '[^a-zA-Z0-9.@_+-]', ''))))
end   AS  "trfmd_secondary_email", 
--
case
  when nullif(lower(ltrim(rtrim("store_address"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("store_address"))), '') is null then null
  else array_join((transform((split(lower(trim("store_address")),' ')), x -> concat(upper(substr(x,1,1)),substr(x,2,length(x))))),' ','')
end   AS  "trfmd_store_address",
-- 
case
  when nullif(lower(ltrim(rtrim("store_city"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("store_city"))), '') is null then null
  else array_join((transform((split(lower(trim("store_city")),' ')), x -> concat(upper(substr(x,1,1)),substr(x,2,length(x))))),' ','')
end   AS  "trfmd_store_city"

FROM

loyalty_profile
