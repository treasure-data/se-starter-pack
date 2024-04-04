-- removed _top from every var table name, updated column names. this can be looped given a list of id columns
WITH temp AS(
  SELECT  *
  FROM
  (
    SELECT SUBSTR(CAST(FROM_UNIXTIME(r.time) AS VARCHAR),1,10)AS datetime , r.time as time_unixtime, 'diff_email' AS key , s.distinct_emailaddress_name_std - r.distinct_with_emailaddress_name_std AS value
    FROM  ${reporting_db}.${prefix}canonical_id_result_key_stats_top r
    ,     ${reporting_db}.${prefix}canonical_id_source_key_stats_top s
    UNION
    SELECT SUBSTR(CAST(FROM_UNIXTIME(r.time) AS VARCHAR),1,10)AS datetime , r.time as time_unixtime, 'diff_client_id' AS key , s.distinct_td_client_id - r.distinct_with_td_client_id AS value
    FROM  ${reporting_db}.${prefix}canonical_id_result_key_stats_top r
    ,     ${reporting_db}.${prefix}canonical_id_source_key_stats_top s
    UNION
    SELECT SUBSTR(CAST(FROM_UNIXTIME(r.time) AS VARCHAR),1,10)AS datetime , r.time as time_unixtime, 'diff_global_id' AS key , s.distinct_td_global_id - r.distinct_with_td_global_id AS value
    FROM  ${reporting_db}.${prefix}canonical_id_result_key_stats_top r
    ,     ${reporting_db}.${prefix}canonical_id_source_key_stats_top s
    UNION
    SELECT SUBSTR(CAST(FROM_UNIXTIME(r.time) AS VARCHAR),1,10)AS datetime , r.time as time_unixtime, 'diff_user_account_id' AS key , s.distinct_useraccountid - r.distinct_with_useraccountid AS value
    FROM  ${reporting_db}.${prefix}canonical_id_result_key_stats_top r
    ,     ${reporting_db}.${prefix}canonical_id_source_key_stats_top s
    UNION
    SELECT SUBSTR(CAST(FROM_UNIXTIME(r.time) AS VARCHAR),1,10)AS datetime , r.time as time_unixtime, 'credit_card_id' AS key , s.distinct_cctype_cclast4_chname_std - r.distinct_with_cctype_cclast4_chname_std AS value
    FROM  ${reporting_db}.${prefix}canonical_id_result_key_stats_top r
    ,     ${reporting_db}.${prefix}canonical_id_source_key_stats_top s
    )
)
SELECT  DISTINCT a.* 
,       b.unified_profiles AS profiles, ${session_id} as session_id
FROM    temp a 
JOIN    ${reporting_db}.${prefix}matching_rate b ON a.datetime = b.datetime