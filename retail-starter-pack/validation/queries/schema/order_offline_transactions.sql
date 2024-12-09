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
    store_id varchar,
    store_address varchar,
    store_city varchar,
    store_state varchar,
    store_postal_code varchar,
    store_country varchar,
    amount double,
    discount_amount double,
    net_amount double,
    time bigint
);