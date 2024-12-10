drop table if exists ${stg}_${sub}.${tbl}; 

create table ${stg}_${sub}.${tbl} as 

SELECT
*,
--
case
  when nullif(lower(ltrim(rtrim("td_host"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("td_host"))), '') is null then null
  else lower(ltrim(rtrim("td_host")))
end   AS  "trfmd_td_host",
--
case
  when nullif(lower(ltrim(rtrim("td_description"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("td_description"))), '') is null then null
  else array_join((transform((split(lower(trim("td_description")),' ')), x -> concat(upper(substr(x,1,1)),substr(x,2,length(x))))),' ','')
end   AS  "trfd_td_description",
--
case
  when nullif(lower(ltrim(rtrim("td_title"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("td_title"))), '') is null then null
  else array_join((transform((split(lower(trim("td_title")),' ')), x -> concat(upper(substr(x,1,1)),substr(x,2,length(x))))),' ','')
end   AS  "trfmd_td_title"


FROM

pageviews