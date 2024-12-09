drop table if exists ${stg}_${sub}.${tbl}; 

create table ${stg}_${sub}.${tbl} as 

SELECT
*,
--
case
  when nullif(lower(ltrim(rtrim("product_name"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("product_name"))), '') is null then null
  else array_join((transform((split(lower(trim("product_name")),' ')), x -> concat(upper(substr(x,1,1)),substr(x,2,length(x))))),' ','')
end   AS  "trfmd_product_name",
--
case
  when nullif(lower(ltrim(rtrim("order_transaction_type"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("order_transaction_type"))), '') is null then null
  else array_join((transform((split(lower(trim("order_transaction_type")),' ')), x -> concat(upper(substr(x,1,1)),substr(x,2,length(x))))),' ','')
end   AS  "trfmd_order_transaction_type",
--
case
  when nullif(lower(ltrim(rtrim("product_department"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("product_department"))), '') is null then null
  else array_join((transform((split(lower(trim("product_department")),' ')), x -> concat(upper(substr(x,1,1)),substr(x,2,length(x))))),' ','')
end   AS  "trfmd_product_department",
--
case
  when nullif(lower(ltrim(rtrim("product_description"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("product_description"))), '') is null then null
  else array_join((transform((split(lower(trim("product_description")),' ')), x -> concat(upper(substr(x,1,1)),substr(x,2,length(x))))),' ','')
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
  else array_join((transform((split(lower(trim("product_sub_department")),' ')), x -> concat(upper(substr(x,1,1)),substr(x,2,length(x))))),' ','')
end   AS  "trfmd_product_sub_department"

FROM

order_details
