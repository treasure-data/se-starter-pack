drop table if exists email_activity_tmp;

create table email_activity_tmp
(
   activity_date varchar ,
   campaign_id varchar ,
   campaign_name varchar ,
   email varchar ,
   unique_guest_id varchar ,
   activity_type varchar ,
   time bigint
);

drop table if exists pageviews_tmp;

create table pageviews_tmp
(
   td_global_id varchar ,
   td_version varchar ,
   td_client_id varchar ,
   td_charset varchar ,
   td_language varchar ,
   td_color varchar ,
   td_screen varchar ,
   td_viewport varchar ,
   td_title varchar ,
   td_description varchar ,
   td_url varchar ,
   td_user_agent varchar ,
   td_platform varchar ,
   td_host varchar ,
   td_path varchar ,
   td_referrer varchar ,
   td_ip varchar ,
   td_browser varchar ,
   td_browser_version varchar ,
   td_os varchar ,
   td_os_version varchar ,
   variant varchar ,
   time bigint
);

drop table if exists ticket_transactions_tmp;

create table  ticket_transactions_tmp (
   unique_loyalty_id bigint ,
   email varchar ,
   phone_number varchar ,
   token bigint ,
   order_no varchar ,
   order_datetime varchar ,
   payment_method varchar ,
   promo_flag bigint ,
   venue_id varchar ,
   venue_name varchar ,
   venue_address varchar ,
   venue_city varchar ,
   venue_state varchar ,
   venue_postal_code varchar ,
   venue_country varchar ,
   amount double ,
   event_name varchar ,
   quantity bigint ,
   seat_category varchar ,
   time bigint
);

drop table if exists event_concessions_transactions_tmp;

create table event_concessions_transactions_tmp (
   unique_loyalty_id varchar ,
   email varchar ,
   phone_number varchar ,
   token varchar ,
   order_no varchar ,
   order_datetime varchar ,
   payment_method varchar ,
   promo_flag bigint ,
   venue_id varchar ,
   venue_name varchar ,
   venue_address varchar ,
   venue_city varchar ,
   venue_state varchar ,
   venue_postal_code varchar ,
   venue_country varchar ,
   amount double ,
   event_name varchar ,
   time bigint
);

drop table if exists event_merchandise_transactions_tmp;

create table event_merchandise_transactions_tmp (
   unique_loyalty_id varchar ,
   email varchar ,
   phone_number varchar ,
   token bigint ,
   order_no varchar ,
   order_datetime varchar ,
   payment_method varchar ,
   promo_flag bigint ,
   venue_id varchar ,
   venue_name varchar ,
   venue_address varchar ,
   venue_city varchar ,
   venue_state varchar ,
   venue_postal_code varchar ,
   venue_country varchar ,
   amount double ,
   event_name varchar ,
   time bigint
);

drop table if exists event_concessions_order_details_tmp;

create table event_concessions_order_details_tmp (
   order_no varchar ,
   order_line_no varchar ,
   order_transaction_type varchar ,
   product_id varchar ,
   quantity double ,
   shipping_cost double ,
   list_price double ,
   discount_offered double ,
   tax double ,
   net_price double ,
   product_size varchar ,
   product_name varchar ,
   product_description varchar ,
   product_department varchar ,
   product_sub_department varchar ,
   time bigint
);

drop table if exists customers_tmp;

create table customers_tmp (
   email varchar ,
   phone_number varchar ,
   first_name varchar ,
   last_name varchar ,
   address varchar ,
   city varchar ,
   state varchar ,
   postal_code varchar ,
   country varchar ,
   gender varchar ,
   date_of_birth varchar ,
   loyalty_status varchar ,
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

drop table if exists online_merchandise_transactions_tmp;

create table online_merchandise_transactions_tmp (
email varchar ,
   phone_number varchar ,
   token bigint ,
   order_no varchar ,
   order_datetime varchar ,
   order_type varchar ,
   payment_method varchar ,
   expidated_ship_flag bigint ,
   promo_flag bigint ,
   markdown_flag bigint ,
   guest_checkout_flag bigint ,
   order_create_datetime varchar ,
   projected_delivery_date varchar ,
   amount double ,
   shipping_cost bigint ,
   time bigint
);


drop table if exists merchandise_order_details_tmp;

create table merchandise_order_details_tmp (
   order_no varchar ,
   order_line_no varchar ,
   order_transaction_type varchar ,
   product_id varchar ,
   quantity double ,
   list_price double ,
   discount_offered double ,
   tax double ,
   net_price double ,
   product_size varchar ,
   product_color varchar ,
   product_name varchar ,
   product_description varchar ,
   product_department varchar ,
   product_sub_department varchar ,
   time bigint
);

drop table if exists favorites_tmp;

create table favorites_tmp (
   unique_loyalty_id varchar ,
   email varchar ,
   favorite varchar ,
   favorite_type varchar ,
   time bigint
);