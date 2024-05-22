SELECT today_datetime as run_date, ${gvar},
       count(1) AS ${gvar}_count
FROM ${intablename}
group by today_datetime, ${gvar}