
SELECT col, (ROW_NUMBER() OVER ())-1 as index
FROM ${prefix}columns_temp
CROSS JOIN UNNEST(all_id_cols) as a(col)