SELECT
*,
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
  when nullif(lower(ltrim(rtrim("phone_number"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("phone_number"))), '') is null then null
  else ARRAY_JOIN(REGEXP_EXTRACT_ALL(replace(lower(ltrim(rtrim("phone_number"))), ' ', ''), '([0-9]+)?'), '')
end   AS  "trfmd_phone_number",
--
case
  when nullif(lower(ltrim(rtrim("order_type"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("order_type"))), '') is null then null
  else regexp_replace(lower(ltrim(rtrim("order_type"))), '(\w)(\w*)', x -> upper(x[1]) || lower(x[2]))
end   AS  "trfmd_order_type",
--
case
  when nullif(lower(ltrim(rtrim("payment_method"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("payment_method"))), '') is null then null
  else regexp_replace(lower(ltrim(rtrim("payment_method"))), '(\w)(\w*)', x -> upper(x[1]) || lower(x[2]))
end   AS  "trfmd_payment_method"

FROM

order_online_transactions