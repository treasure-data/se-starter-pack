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

-- Get the max time from the destination table
max_time_existing AS (
    SELECT COALESCE(MAX(time), 0) as max_time
    FROM ${src}_${sub}.${tbl.src_table_name}
),

flattened AS (
    SELECT 
        ARRAY_JOIN(ARRAY_AGG(CONCAT(
            CASE 
                WHEN src = 'time' then raw
                WHEN (raw IS NULL OR CAST(raw AS VARCHAR) = 'null') 
                    THEN CONCAT('CAST(null AS ', type, ')')
                ELSE CONCAT('TRY_CAST(',raw,' AS ', type, ')')
            END,
            ' as ', 
            src
        )), ',') as mapped_cols
    from (
        SELECT 
            map['src'] as src,
            map['raw'] as raw,
            map['type'] as type
        FROM json_data
        CROSS JOIN UNNEST(CAST(data AS ARRAY<MAP<VARCHAR, VARCHAR>>)) AS t(map)
    )
)

SELECT 
    
    CONCAT(
      'SELECT ', 
      CASE 
        WHEN ${JSON.parse(include_all_raw_cols)} = true THEN CONCAT(mapped_cols,',', raw_cols)
        ELSE mapped_cols END,
      ' FROM ', 
      '${tbl.raw_table_name}',
      ' WHERE time > ', (SELECT CAST(max_time as VARCHAR) FROM max_time_existing)
      ) as qry
FROM flattened, raw
 