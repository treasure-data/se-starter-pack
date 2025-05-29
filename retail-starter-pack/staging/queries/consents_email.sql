SELECT
*,
--
cast(COALESCE(regexp_like( "id", '^(?=.{1,256})(?=.{1,64}@.{1,255}$)[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$'), false) as varchar)  AS  "valid_email_flag",
--
case
  when nullif(lower(ltrim(rtrim("consent_type"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("consent_type"))), '') is null then null
  else array_join((transform((split(lower(trim("consent_type")),' ')), x -> concat(upper(substr(x,1,1)),substr(x,2,length(x))))),' ','')
end   AS  "trfmd_consent_type",
--
case
  when nullif(lower(ltrim(rtrim("id"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("id"))), '') is null then null
  when nullif(lower(trim("id")), '') in (select lower(trim(invalid_email)) from ${stg}_${sub}.invalid_emails ) then null
  else lower(ltrim(rtrim(regexp_replace("id", '[^a-zA-Z0-9.@_+-]', ''))))
end   AS  "trfmd_email",
--
case
  when nullif(lower(ltrim(rtrim("consent_flag"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("consent_flag"))), '') is null then null
  when nullif(lower(ltrim(rtrim("consent_flag"))), '') in ('0', 'false') then 'False'
  when nullif(lower(ltrim(rtrim("consent_flag"))), '') in ('1', 'true') then 'True'
end   AS  "trfmd_consent_flag",
case
  when nullif(lower(ltrim(rtrim("id_type"))), 'null') is null then null
  when nullif(lower(ltrim(rtrim("id_type"))), '') is null then null
  else array_join((transform((split(lower(trim("id_type")),' ')), x -> concat(upper(substr(x,1,1)),substr(x,2,length(x))))),' ','')
end   AS  "trfmd_id_type"

FROM

consents
where lower(id_type) = 'email'
