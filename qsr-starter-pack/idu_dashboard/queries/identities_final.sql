select T1.* , 
T1.time as time_unixtime,
substr(cast(from_unixtime(T1.time) as VARCHAR),1,10) as datetime,
T2.id_type  
from ${prefix}identities_temp T1
LEFT JOIN ${prefix}column_mapping T2
ON T1.column_name = T2.source_table_id