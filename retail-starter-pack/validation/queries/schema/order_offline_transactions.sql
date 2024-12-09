drop table if exists order_offline_transactions_tmp;

create table order_offline_transactions_tmp (
    customer_id varchar,
    email varchar,
    phone_number varchar,
    token varchar,
    order_no varchar,
    order_datetime varchar,
    payment_method varchar,
    promo_code varchar,
    markdown_flag varchar,
    location_id varchar,
    location_address varchar,
    location_city varchar,
    location_state varchar,
    location_postal_code varchar,
    location_country varchar,
    amount double,
    discount_amount double,
    net_amount double,
    time bigint
);