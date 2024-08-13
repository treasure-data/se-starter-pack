drop table if  exists customers_tmp;

create table customers_tmp
(
   email varchar,
   phone_number varchar,
   first_name varchar,
   last_name varchar,
   address varchar,
   city varchar,
   state varchar,
   postal_code varchar,
   country varchar,
   gender varchar,
   date_of_birth varchar,
   loyalty_status varchar,
  --  customer_makeme_fail varchar,
   time bigint
);

drop table if  exists pageviews_tmp;

create table pageviews_tmp 
(
   td_global_id varchar,
   td_version varchar,
   td_client_id varchar,
   td_charset varchar,
   td_language varchar,
   td_color varchar,
   td_screen varchar,
   td_viewport varchar,
   td_title varchar,
   td_description varchar,
   td_url varchar,
   td_user_agent varchar,
   td_platform varchar,
   td_host varchar,
   td_path varchar,
   td_referrer varchar,
   td_ip varchar,
   td_browser varchar,
   td_browser_version varchar,
   td_os varchar,
   td_os_version varchar,
   time bigint
);

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

drop table if exists order_online_transactions_tmp;

create table order_online_transactions_tmp (
   email varchar,
   phone_number varchar,
   token varchar,
   order_no varchar,
   order_datetime varchar,
   payment_method varchar,
   shipping_cost double,
   expidated_ship_flag varchar,
   promo_flag varchar,
   markdown_flag varchar,
   guest_checkout_flag varchar,
   order_create_datetime varchar,
   projected_delivery_date varchar,
   amount double,
   time bigint
);

drop table if exists order_offline_transactions_tmp;

create table order_offline_transactions_tmp (
   customer_id varchar,
   email varchar,
   phone_number varchar,  
   token varchar,
   order_no varchar,
   order_datetime varchar,
   payment_method varchar,
   promo_flag varchar,
   markdown_flag varchar,
   store_id varchar,
   store_address varchar,
   store_city varchar,
   store_state varchar,
   store_postal_code varchar,
   store_country varchar,
   amount double, 
   time bigint
);

drop table if exists order_details_tmp;

create table order_details_tmp (
   order_no varchar,
   order_line_no varchar,
   order_transaction_type varchar,
   product_id varchar,
   quantity bigint,
   list_price double,
   discount_offered double,
   tax double,
   net_price double,
   product_name varchar,
   product_description varchar,
   product_size varchar,
   product_color varchar,
   product_department varchar,
   product_sub_department varchar,      
   time bigint
);

drop table if exists formfills_tmp;

create table formfills_tmp (
   email varchar,
   phone_number varchar,
   td_global_id varchar,
   td_client_id varchar, 
   form_type varchar,  
   time bigint
);

drop table if exists consents_tmp;

create table consents_tmp (
   id varchar,
   id_type varchar,
   consent_type varchar,
   consent_flag varchar,
   time bigint
);
