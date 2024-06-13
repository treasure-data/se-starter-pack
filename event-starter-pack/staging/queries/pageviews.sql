SELECT
*,
--
case
  when nullif(lower(ltrim(rtrim("td_host"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("td_host"))), '') is null then null
  else lower(ltrim(rtrim("td_host")))
end   AS  "trfmd_td_host"

FROM

pageviews