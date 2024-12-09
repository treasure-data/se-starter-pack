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
    projected_delivery_date as varchar
    bopis_flag as varchar,
    store_id as varchar,
    store_address as varchar,
    store_city as varchar,
    store_state as varchar,
    store_postal_code as varchar,
    store_country as varchar,
    markdown_flag varchar,
    guest_checkout_flag varchar,
    order_transaction_type varchar,
    amount double,
    discount_amount double,
    net_amount double,
    shipping_cost as bigint,
    expidated_ship_flag as varchar,
    time bigint
);