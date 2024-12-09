with email_cte as (select
trfmd_activity_date_unix as trfmd_activity_date_unix,
${unification_id},
activity_type as activity_type
 from email_activity),

email_attributes as (select
${unification_id},
max(CASE WHEN lower(activity_type) = 'email_sent' THEN trfmd_activity_date_unix ELSE NULL END) AS last_email_date_unix,
CASE WHEN 
    count(CASE WHEN lower(activity_type) = 'email_hardbounced' THEN activity_type ELSE NULL END) > 0 THEN 'True' 
    ELSE 'False' 
    END 
AS email_hardbounce
 
 from
email_cte
group by ${unification_id})

select * from email_attributes