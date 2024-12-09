
drop table if exists email_activity_tmp;

create table  email_activity_tmp (
  activity_date varchar,
  campaign_id varchar,
  campaign_name varchar,
  email varchar,
  customer_id varchar,
  activity_type varchar,
  time bigint
);
