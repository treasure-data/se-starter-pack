SELECT  DISTINCT A.* 
,       B.unified_profiles AS profiles
FROM    ${prefix}merge_keys_updated_temp A 
JOIN    ${reporting_db}.${prefix}matching_rate B ON A.datetime = B.datetime


