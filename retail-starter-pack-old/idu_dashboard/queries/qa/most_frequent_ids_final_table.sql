SELECT 
column_name, 
col_value, 
CARDINALITY(ARRAY_AGG(DISTINCT unification_table)) as num_src_tables, 
ARRAY_AGG(DISTINCT unification_table) as src_table_list,  
SUM(value_counts) as total_occurences
FROM idu_qa_frequent_ids_temp
GROUP BY 1, 2