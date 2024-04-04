select DISTINCT time as time_unixtime, substr(cast(from_unixtime(time) as VARCHAR),1,10) as datetime,

${td.last_results.query_syntax}
from ${prefix}avg_min_max a




