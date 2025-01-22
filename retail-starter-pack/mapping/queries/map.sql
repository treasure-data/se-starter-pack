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
      '${tbl.raw_table_name}'
      ) as qry
FROM flattened, raw
 