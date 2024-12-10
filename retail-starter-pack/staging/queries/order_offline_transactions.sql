
drop table if exists ${stg}_${sub}.${tbl}; 

create table ${stg}_${sub}.${tbl} as 

SELECT
*,
--
TD_TIME_PARSE(order_datetime) as trfmd_order_datetime_unix,
--
case
  when nullif(lower(ltrim(rtrim("store_address"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("store_address"))), '') is null then null
  else array_join((transform((split(lower(trim("store_address")),' ')), x -> concat(upper(substr(x,1,1)),substr(x,2,length(x))))),' ','')
end   AS  "trfmd_store_address",
--
case
  when nullif(lower(ltrim(rtrim("store_postal_code"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("store_postal_code"))), '') is null then null
  else lower(ltrim(rtrim("store_postal_code")))
end   AS  "trfmd_store_postal_code",
--
case
  when nullif(lower(ltrim(rtrim("store_city"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("store_city"))), '') is null then null
  else array_join((transform((split(lower(trim("store_city")),' ')), x -> concat(upper(substr(x,1,1)),substr(x,2,length(x))))),' ','')
end   AS  "trfmd_store_city",
--
case
  when nullif(lower(ltrim(rtrim("store_state"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("store_state"))), '') is null then null
  else array_join((transform((split(lower(trim("store_state")),' ')), x -> concat(upper(substr(x,1,1)),substr(x,2,length(x))))),' ','')
end   AS  "trfmd_store_state",
--
case
  when month(from_unixtime(TD_TIME_PARSE(order_datetime))) in (12, 1, 2) then 'Winter'
  when month(from_unixtime(TD_TIME_PARSE(order_datetime))) in (3, 4, 5) then 'Spring'
  when month(from_unixtime(TD_TIME_PARSE(order_datetime))) in (6, 7, 8) then 'Summer'
  when month(from_unixtime(TD_TIME_PARSE(order_datetime))) in (9, 10, 11) then 'Fall'
  else null
end   AS  "trfmd_season",
--
cast(COALESCE(regexp_like( "email", '^(?=.{1,256})(?=.{1,64}@.{1,255}$)[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$'), false) as varchar)  AS  "valid_email_flag",
--
case
  when nullif(lower(ltrim(rtrim("email"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("email"))), '') is null then null
  else lower(ltrim(rtrim(regexp_replace("email", '[^a-zA-Z0-9.@_+-]', ''))))
end   AS  "trfmd_email",
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
  else array_join((transform((split(lower(trim("payment_method")),' ')), x -> concat(upper(substr(x,1,1)),substr(x,2,length(x))))),' ','')
end   AS  "trfmd_payment_method",
--
case
  when nullif(lower(ltrim(rtrim("store_country"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("store_country"))), '') is null then null
  else array_join((transform((split(lower(trim("store_country")),' ')), x -> concat(upper(substr(x,1,1)),substr(x,2,length(x))))),' ','')
end   AS  "trfmd_store_country",
--
case
  when nullif(lower(ltrim(rtrim("markdown_flag"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("markdown_flag"))), '') is null then null
  when nullif(lower(ltrim(rtrim("markdown_flag"))), '') in ('0', 'false') then 'False'
  when nullif(lower(ltrim(rtrim("markdown_flag"))), '') in ('1', 'true') then 'True'
end   AS  "trfmd_markdown_flag",
--
case
  when nullif(lower(ltrim(rtrim("promo_code"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("promo_code"))), '') is null then null
  else array_join((transform((split(lower(trim("promo_code")),' ')), x -> concat(upper(substr(x,1,1)),substr(x,2,length(x))))),' ','')
end   AS  "trfmd_promo_code"
FROM

order_offline_transactions
