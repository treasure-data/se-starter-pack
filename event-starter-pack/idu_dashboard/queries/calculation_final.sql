select *, 
time as time_unixtime,
TD_TIME_STRING(time, 'm!') as datetime
from ${prefix}calculations_2