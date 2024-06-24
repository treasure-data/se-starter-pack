with base as (select
    event_unification_id
  , sum(CASE WHEN time >= try_cast(to_unixtime(date_trunc('day', now()) - interval '7' day) as integer) THEN 1 ELSE 0 END) AS web_visits_last_7days_sum
  from enriched_pageviews
  group by event_unification_id
)
select event_unification_id
, case when web_visits_last_7days_sum > 0 then 'True' else 'False' end web_visits_last_7days
from base