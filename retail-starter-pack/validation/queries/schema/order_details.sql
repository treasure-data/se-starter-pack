drop table if exists order_details_tmp;

create table order_details_tmp (
    order_no varchar,
    order_transaction_type varchar,
    quantity bigint,
    product_id varchar,
    product_color varchar,
    product_name varchar,
    product_size varchar,
    product_description varchar,
    product_department varchar,
    product_sub_department varchar,
    list_price double,
    discount_offered double,
    tax double,
    net_price double,
    order_line_no bigint,
    time bigint
);