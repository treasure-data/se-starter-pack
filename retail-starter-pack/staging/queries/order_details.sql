SELECT
*,
--
case
  when nullif(lower(ltrim(rtrim("product_name"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("product_name"))), '') is null then null
  else regexp_replace(lower(ltrim(rtrim("product_name"))), '(\w)(\w*)', x -> upper(x[1]) || lower(x[2]))
end   AS  "trfmd_product_name",
--
case
  when nullif(lower(ltrim(rtrim("order_transaction_type"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("order_transaction_type"))), '') is null then null
  else regexp_replace(lower(ltrim(rtrim("order_transaction_type"))), '(\w)(\w*)', x -> upper(x[1]) || lower(x[2]))
end   AS  "trfmd_order_transaction_type",
--
case
  when nullif(lower(ltrim(rtrim("product_department"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("product_department"))), '') is null then null
  else regexp_replace(lower(ltrim(rtrim("product_department"))), '(\w)(\w*)', x -> upper(x[1]) || lower(x[2]))
end   AS  "trfmd_product_department",
--
case
  when nullif(lower(ltrim(rtrim("product_color"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("product_color"))), '') is null then null
  else regexp_replace(lower(ltrim(rtrim("product_color"))), '(\w)(\w*)', x -> upper(x[1]) || lower(x[2]))
end   AS  "trfmd_product_color",
--
case
  when nullif(lower(ltrim(rtrim("product_description"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("product_description"))), '') is null then null
  else regexp_replace(lower(ltrim(rtrim("product_description"))), '(\w)(\w*)', x -> upper(x[1]) || lower(x[2]))
end   AS  "trfmd_product_description",
--
case
  when nullif(lower(ltrim(rtrim("product_size"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("product_size"))), '') is null then null
  else lower(ltrim(rtrim("product_size")))
end   AS  "trfmd_product_size",
--
case
  when nullif(lower(ltrim(rtrim("product_sub_department"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("product_sub_department"))), '') is null then null
  else regexp_replace(lower(ltrim(rtrim("product_sub_department"))), '(\w)(\w*)', x -> upper(x[1]) || lower(x[2]))
end   AS  "trfmd_product_sub_department"

FROM

order_details