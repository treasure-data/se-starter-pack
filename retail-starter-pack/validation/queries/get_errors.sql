with agg as (
  select issue, map_agg(type, cnt) js, sum(cnt) tot
  from report_deviation
  group by issue
)
select  case when js['missing_tables'] > 0 and js['missing_columns'] > 0 and js['mismatch_column_type'] > 0
             then 'Error: Missing tables ,columns and  mismatched column types from source database ${src}_${sub}. Stopping workflow!' 
             when js['missing_tables'] > 0 and js['missing_columns'] > 0 and js['mismatch_column_type'] = 0
             then 'Error: Missing tables and columns from source database ${src}_${sub}. Stopping workflow!' 
             when js['missing_tables'] > 0 and js['missing_columns'] = 0 and js['mismatch_column_type'] = 0
             then 'Error: Missing tables from source database ${src}_${sub}. Stopping workflow!'
             when js['missing_tables'] = 0 and js['missing_columns'] > 0 and js['mismatch_column_type'] = 0
             then 'Error: Missing columns from source database ${src}_${sub}. Stopping workflow!'
             when js['missing_tables'] = 0 and js['missing_columns'] = 0 and js['mismatch_column_type'] > 0
             then 'Error: Mismatched column types from source database ${src}_${sub}. Stopping workflow!'                               
        end as subject,
        case when js['missing_tables'] > 0 and js['missing_columns'] > 0 and js['mismatch_column_type'] > 0
             then 'Check va_config_${sub}.report_missing_tables_in_src for missing tables, va_config_${sub}.report_missing_src_columns for missing columns and va_config_${sub}.report_column_type_mismatches for column type mismatches in source database ${src}_${sub}.' 
             when js['missing_tables'] > 0 and js['missing_columns'] > 0 and js['mismatch_column_type'] = 0
             then 'Check va_config_${sub}.report_missing_tables_in_src for missing tables and va_config_${sub}.report_missing_src_columns for missing columns in source database ${src}_${sub}.' 
             when js['missing_tables'] > 0 and js['missing_columns'] = 0 and js['mismatch_column_type'] = 0
             then 'Check va_config_${sub}.report_missing_tables_in_src for missing tables in source database ${src}_${sub}.' 
             when js['missing_tables'] = 0 and js['missing_columns'] > 0 and js['mismatch_column_type'] = 0
             then 'Check va_config_${sub}.report_missing_src_columns for missing columns in source database ${src}_${sub}.' 
             when js['missing_tables'] = 0 and js['missing_columns'] = 0 and js['mismatch_column_type'] > 0
             then 'Check va_config_${sub}.report_column_type_mismatches for column type mismatches in source database ${src}_${sub}'                               
        end as message         
from agg
where issue = 'error'
and tot > 0;