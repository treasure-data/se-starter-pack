SELECT
*,
--
case
  when nullif(lower(ltrim(rtrim("store_postal_code"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("store_postal_code"))), '') is null then null
  else regexp_replace(lower(ltrim(rtrim("store_postal_code"))), '(\w)(\w*)', x -> upper(x[1]) || lower(x[2]))
end   AS  "trfmd_store_postal_code",
--
case
  when nullif(lower(ltrim(rtrim("store_city"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("store_city"))), '') is null then null
  else regexp_replace(lower(ltrim(rtrim("store_city"))), '(\w)(\w*)', x -> upper(x[1]) || lower(x[2]))
end   AS  "trfmd_store_city",
--
case
  when nullif(lower(ltrim(rtrim("store_state"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("store_state"))), '') is null then null
  else regexp_replace(lower(ltrim(rtrim("store_state"))), '(\w)(\w*)', x -> upper(x[1]) || lower(x[2]))
end   AS  "trfmd_store_state",
--
case
  when month(from_unixtime(order_datetime)) in (12, 1, 2) then 'Winter'
  when month(from_unixtime(order_datetime)) in (3, 4, 5) then 'Spring'
  when month(from_unixtime(order_datetime)) in (6, 7, 8) then 'Summer'
  when month(from_unixtime(order_datetime)) in (9, 10, 11) then 'Fall'
  else null
end   AS  "trfmd_season",
--
cast(COALESCE(regexp_like( "email", '^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z0-9]{2,})$'), false) as varchar)  AS  "valid_email_flag",
--
case
  when nullif(lower(ltrim(rtrim("email"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("email"))), '') is null then null
  else lower(ltrim(rtrim("email")))
end   AS  "trfmd_email",
--
case
  when nullif(lower(ltrim(rtrim("store_address"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("store_address"))), '') is null then null
  else regexp_replace(lower(ltrim(rtrim("store_address"))), '(\w)(\w*)', x -> upper(x[1]) || lower(x[2]))
end   AS  "trfmd_store_address",
--
case
  when nullif(lower(ltrim(rtrim("phone_number"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("phone_number"))), '') is null then null
  else ARRAY_JOIN(REGEXP_EXTRACT_ALL(replace(lower(ltrim(rtrim("phone_number"))), ' ', ''), '([0-9]+)?'), '')
end   AS  "trfmd_phone_number",
--
case
  when nullif(lower(ltrim(rtrim("payment_method"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("payment_method"))), '') is null then null
  else regexp_replace(lower(ltrim(rtrim("payment_method"))), '(\w)(\w*)', x -> upper(x[1]) || lower(x[2]))
end   AS  "trfmd_payment_method",
--
case
  when nullif(lower(ltrim(rtrim("store_country"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("store_country"))), '') is null then null
  else regexp_replace(lower(ltrim(rtrim("store_country"))), '(\w)(\w*)', x -> upper(x[1]) || lower(x[2]))
end   AS  "trfmd_store_country"

FROM

order_offline_transactions