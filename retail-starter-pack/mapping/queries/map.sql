WITH json_data AS (
    SELECT 
        json_parse('${tbl.columns}') AS data
), 

prp as (
    select 
        ARRAY_JOIN(ARRAY_AGG(CONCAT(column_name, ' as prp_', column_name )), ',') as prp_cols
    from information_schema.columns 
  where table_name = '${tbl.prp_table_name}' 
  and table_schema = '${prp}_${sub}'
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
                WHEN src = 'time' then prp
                WHEN (prp IS NULL OR CAST(prp AS VARCHAR) = 'null') 
                    THEN CONCAT('CAST(null AS ', type, ')')
                ELSE CONCAT('TRY_CAST(',prp,' AS ', type, ')')
            END,
            ' as ', 
            src
        )), ',') as mapped_cols
    from (
        SELECT 
            map['src'] as src,
            map['prp'] as prp,
            map['type'] as type
        FROM json_data
        CROSS JOIN UNNEST(CAST(data AS ARRAY<MAP<VARCHAR, VARCHAR>>)) AS t(map)
    )
)

SELECT 
    
    CONCAT(
      'SELECT ', 
      CASE 
        WHEN ${JSON.parse(include_all_prp_cols)} = true THEN CONCAT(mapped_cols,',', prp_cols)
        ELSE mapped_cols END,
      ' FROM ', 
      '${tbl.prp_table_name}',
      ' WHERE time > ', (SELECT CAST(max_time as VARCHAR) FROM max_time_existing)
      ) as qry
FROM flattened, prp
 