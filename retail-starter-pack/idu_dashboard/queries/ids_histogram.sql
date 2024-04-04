WITH  raw AS (
  SELECT  split(histogram_emailaddress_name_std,',') AS hist , 'email' AS id_type
  FROM    ${source_db}.${canonical_id_col}_result_key_stats
  WHERE   1=1
  AND     from_table = '*'
  AND     time = (SELECT MAX(time) FROM ${source_db}.${canonical_id_col}_result_key_stats)
  UNION
  SELECT  split(histogram_td_client_id,',') AS hist , 'cookie_1p' AS id_type
  FROM    ${source_db}.${canonical_id_col}_result_key_stats
  WHERE   1=1
  AND     from_table = '*'
  AND     time = (SELECT MAX(time) FROM ${source_db}.${canonical_id_col}_result_key_stats)
  UNION
  SELECT  split(histogram_td_global_id,',') AS hist , 'cookie_3p' AS id_type
  FROM    ${source_db}.${canonical_id_col}_result_key_stats
  WHERE   1=1
  AND     from_table = '*'
  AND     time = (SELECT MAX(time) FROM ${source_db}.${canonical_id_col}_result_key_stats)
  UNION
  SELECT  split(histogram_useraccountid,',') AS hist , 'user_account_id' AS id_type -- changed from histogram_td_ssc_id 
  FROM    ${source_db}.${canonical_id_col}_result_key_stats
  WHERE   1=1
  AND     from_table = '*'
  AND     time = (SELECT MAX(time) FROM ${source_db}.${canonical_id_col}_result_key_stats)
)
SELECT    element_at(b,1) AS num_times, cast(element_at(b,2) AS integer) AS ids, id_type, ${session_id} as session_id
FROM    (
          SELECT  split(value,':') AS b, id_type
          FROM    raw
          CROSS JOIN UNNEST (raw.hist) AS t (value)
)