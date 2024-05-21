SELECT
*,
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
  when nullif(lower(ltrim(rtrim("loyalty_status"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("loyalty_status"))), '') is null then null
  else array_join((transform((split(lower(trim("loyalty_status")),' ')), x -> concat(upper(substr(x,1,1)),substr(x,2,length(x))))),' ','')
end   AS  "trfmd_loyalty_status",
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
date_diff('year', date_parse(date_of_birth, '%Y-%m-%d'), current_date)   AS  "trfmd_age",
--
case
  when nullif(lower(ltrim(rtrim("email"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("email"))), '') is null then null
  else lower(ltrim(rtrim(regexp_replace("email", '[^a-zA-Z0-9.@_+-]', ''))))
end   AS  "trfmd_email"

FROM

customers
