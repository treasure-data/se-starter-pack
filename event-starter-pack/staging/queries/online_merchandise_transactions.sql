SELECT
*,
--
TD_TIME_PARSE(order_datetime) as trfmd_order_datetime_unix,
TD_TIME_PARSE(order_create_datetime) as trfmd_order_create_datetime_unix,
TD_TIME_PARSE(projected_delivery_date) as trfmd_projected_delivery_date_unix,
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
  when nullif(lower(ltrim(rtrim("store_name"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("store_name"))), '') is null then null
  else array_join((transform((split(lower(trim("store_name")),' ')), x -> concat(upper(substr(x,1,1)),substr(x,2,length(x))))),' ','')
end   AS  "trfmd_store_name",
--
case
  when nullif(lower(ltrim(rtrim("expedited_ship_flag"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("expedited_ship_flag"))), '') is null then null
  when nullif(lower(ltrim(rtrim("expedited_ship_flag"))), '') in ('0', 'false') then 'False'
  when nullif(lower(ltrim(rtrim("expedited_ship_flag"))), '') in ('1', 'true') then 'True'
end   AS  "trfmd_expedited_ship_flag",
--
case
  when nullif(lower(ltrim(rtrim("promo_flag"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("promo_flag"))), '') is null then null
  when nullif(lower(ltrim(rtrim("promo_flag"))), '') in ('0', 'false') then 'False'
  when nullif(lower(ltrim(rtrim("promo_flag"))), '') in ('1', 'true') then 'True'
end   AS  "trfmd_promo_flag",
--
case
  when nullif(lower(ltrim(rtrim("markdown_flag"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("markdown_flag"))), '') is null then null
  when nullif(lower(ltrim(rtrim("markdown_flag"))), '') in ('0', 'false') then 'False'
  when nullif(lower(ltrim(rtrim("markdown_flag"))), '') in ('1', 'true') then 'True'
end   AS  "trfmd_markdown_flag",
--
case
  when nullif(lower(ltrim(rtrim("guest_checkout_flag"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("guest_checkout_flag"))), '') is null then null
  when nullif(lower(ltrim(rtrim("guest_checkout_flag"))), '') in ('0', 'false') then 'False'
  when nullif(lower(ltrim(rtrim("guest_checkout_flag"))), '') in ('1', 'true') then 'True'
end   AS  "trfmd_guest_checkout_flag"

FROM

online_merchandise_transactions