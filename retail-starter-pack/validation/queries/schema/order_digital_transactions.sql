drop table if exists order_digital_transactions_tmp;

create table order_digital_transactions_tmp (
    customer_id varchar,
    email varchar,
    phone_number varchar,
    token varchar,
    order_no varchar,
    order_datetime varchar,
    payment_method varchar,
    promo_code varchar,
    projected_delivery_date varchar,
    bopis_flag varchar,
    store_id varchar,
    store_address varchar,
    store_city varchar,
    store_state varchar,
    store_postal_code varchar,
    store_country varchar,
    markdown_flag varchar,
    guest_checkout_flag varchar,
    order_transaction_type varchar,
    amount double,
    discount_amount double,
    net_amount double,
    shipping_cost bigint,
    expidated_ship_flag varchar,
    time bigint
);