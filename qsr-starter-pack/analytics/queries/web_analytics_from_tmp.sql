SELECT today_datetime as run_date, ${parray},
       count(1) AS ${parray}_count
FROM web_analytics_agg_tmp
group by today_datetime, ${parray}