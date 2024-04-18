SELECT
*,
--
cast(COALESCE(regexp_like( "email", '^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z0-9]{2,})$'), false) as varchar)  AS  "valid_email_flag",
--
case
  when nullif(lower(ltrim(rtrim("activity_type"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("activity_type"))), '') is null then null
  else lower(ltrim(rtrim("activity_type")))
end   AS  "trfmd_activity_type",
--
case
  when nullif(lower(ltrim(rtrim("campaign_name"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("campaign_name"))), '') is null then null
  else regexp_replace(lower(ltrim(rtrim("campaign_name"))), '(\w)(\w*)', x -> upper(x[1]) || lower(x[2]))
end   AS  "trfmd_campaign_name",
--
case
  when nullif(lower(ltrim(rtrim("email"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("email"))), '') is null then null
  else lower(ltrim(rtrim("email")))
end   AS  "trfmd_email"

FROM

email_activity