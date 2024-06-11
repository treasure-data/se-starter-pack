with get_utm as (
  select retail_unification_id, session_id, max(utm_source) utm_source, max(utm_medium) utm_medium, max(utm_campaign) utm_campaign
  from web_analytics_agg_tmp
  group by retail_unification_id, session_id
),
t1 as (
  select distinct retail_unification_id, session_id
  from web_analytics_agg_tmp
  where regexp_like(${column}, '${conversion.pattern}')
)
select today_datetime as run_date, ${parray}, count(t1.session_id) as ${parray}_count
from t1 left join get_utm
on (t1.session_id = get_utm.session_id)
group by today_datetime, ${parray};