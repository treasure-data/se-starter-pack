SELECT
*,
case
  when nullif(lower(ltrim(rtrim("country"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("country"))), '') is null then null
  else lower(ltrim(rtrim("country")))
end   AS  "trfmd_country",
--
concat(first_name,' ',last_name)   AS  "trfmd_full_name",
--
case
  when nullif(lower(ltrim(rtrim("state"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("state"))), '') is null then null
  else lower(ltrim(rtrim("state")))
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
  else lower(ltrim(rtrim("first_name")))
end   AS  "trfmd_first_name",
--
case
  when nullif(lower(ltrim(rtrim("last_name"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("last_name"))), '') is null then null
  else lower(ltrim(rtrim("last_name")))
end   AS  "trfmd_last_name",
--
cast(COALESCE(regexp_like( "email", '^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z0-9]{2,})$'), false) as varchar)  AS  "valid_email_flag",
--
case
  when nullif(lower(ltrim(rtrim("loyalty_status"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("loyalty_status"))), '') is null then null
  else lower(ltrim(rtrim("loyalty_status")))
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
  else lower(ltrim(rtrim("address")))
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
  else lower(ltrim(rtrim("city")))
end   AS  "trfmd_city",
--
date_diff('year', date_parse(date_of_birth, '%Y-%m-%d'), current_date)   AS  "trfmd_age",
--
case
  when nullif(lower(ltrim(rtrim("email"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("email"))), '') is null then null
  else lower(ltrim(rtrim("email")))
end   AS  "trfmd_email"

FROM

customers