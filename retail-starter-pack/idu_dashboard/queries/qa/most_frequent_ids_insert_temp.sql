SELECT
'${td.each.unification_table}' as unification_table,
'${td.each.column_name}' as column_name,
TRY(CAST(${td.each.column_name_src} AS VARCHAR)) as col_value,
count(*) as value_counts
FROM ${td.each.unification_table}
WHERE ${td.each.column_name_src} IS NOT NULL
GROUP BY 1, 2, 3
ORDER BY 4 desc
LIMIT ${top_k_most_freq_ids}