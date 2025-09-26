with sms_activity_cte as (
  select 
    ${unification_id}, 
    activity_type
  from sms_activity
)

select 
  ${unification_id}, 
  COUNT_IF(activity_type = 'sms.message_link_click') as sms_click_count
FROM 
  sms_activity_cte
GROUP BY 1
