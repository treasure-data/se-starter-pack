select  T1.*
from    ${source_db}.${canonical_id_col}_source_key_stats T1
where   from_table ='*' 
order by time desc 
limit 1