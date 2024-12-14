WITH json_data AS (
    SELECT 
        json_parse('${tbl.columns}') AS data
), 

raw as (
  select 
    ARRAY_JOIN(ARRAY_AGG(CONCAT(column_name, ' as raw_', column_name )), ',') as raw_cols
  from information_schema.columns 
  where table_name = '${tbl.raw_table_name}' 
  and table_schema = '${raw}_${sub}'
), 

flattened AS (
  SELECT ARRAY_JOIN(ARRAY_AGG(CONCAT(key, ' as ', value)), ',') as mapped_cols
  from (
    SELECT 
        kv.key as key,
        COALESCE(CAST(kv.value AS VARCHAR), 'null') as value
    FROM json_data
    CROSS JOIN UNNEST(CAST(data AS ARRAY<MAP<VARCHAR, VARCHAR>>)) AS t(map)
    CROSS JOIN UNNEST(map) AS kv(key, value)
  )
)
SELECT 
    
    CONCAT(
      'SELECT ', 
      CASE 
        WHEN ${JSON.parse(include_all_raw_cols)} = true THEN CONCAT(mapped_cols,',', raw_cols)
        ELSE mapped_cols END,
      ' FROM ', 
      '${tbl.raw_table_name}'
      ) as qry
FROM flattened, raw
 