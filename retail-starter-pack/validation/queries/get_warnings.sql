with agg as (
  select issue, map_agg(type, cnt) js, sum(cnt) tot
  from report_deviation
  group by issue
)
select  case when js['extra_tables'] > 0 and js['extra_columns'] > 0
             then 'Warning: Extra tables and extra columns found in source database ${src}_${sub}.' 
             when js['extra_columns'] > 0 and js['extra_tables'] = 0
             then 'Warning: Extra columns found in source database ${src}_${sub}.'
             when js['extra_tables'] > 0 and js['extra_tables'] = 0
             then 'Warning: Extra tables found in source database ${src}_${sub}.'
        end as subject,
        case when js['extra_tables'] > 0 and js['extra_columns'] > 0
             then 'Check va_config_${sub}.report_extra_tables_in_src for extra tables and va_config_${sub}.report_extra_columns_in_src for extra columns in source database ${src}_${sub}.'
             when js['extra_columns'] > 0 and js['extra_tables'] = 0
             then 'Check va_config_${sub}.report_extra_columns_in_src for extra columns in source database ${src}_${sub}.'
             when js['extra_tables'] > 0 and js['extra_tables'] = 0
             then 'Check va_config_${sub}.report_extra_tables_in_src for extra tables in source database ${src}_${sub}.'
        end as message         
from agg
where issue = 'warning'
and tot > 0;