
with pageviews_cte as 
(select
time as time,
${unification_id} as ${unification_id}
 from pageviews),

pageviews_attributes as (select
${unification_id},
count(CASE WHEN time >= try_cast(to_unixtime(date_trunc('day', now()) - interval '7' day) as integer) THEN ${unification_id} ELSE NULL END) AS web_visits_last_7days
 from
pageviews_cte
group by ${unification_id})

select * from pageviews_attributes