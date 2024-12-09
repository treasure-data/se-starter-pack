select a.* ,
b.date,
b.duration,
b.session_unixtime,
b.session_time
from ${prefix}calculations_temp a
join ${prefix}session_information b
on a.join_key = b.join_key