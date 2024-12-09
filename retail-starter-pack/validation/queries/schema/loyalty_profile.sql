drop table if  exists loyalty_profile_tmp;

create table loyalty_profile_tmp
(
    customer_id varchar,
    email varchar,
    secondary_email varchar,
    phone_number varchar,
    first_name varchar,
    last_name varchar,
    address varchar,
    country varchar,
    city varchar,
    state varchar,
    postal_code varchar,
    gender varchar,
    date_of_birth varchar,
    membership_status varchar,
    membership_tier varchar,
    net_redeemable_balance double,
    net_debits double,
    membership_points_earned bigint,
    membership_points_balance bigint,
    membership_points_pending bigint,
    total_loyalty_purchases bigint,
    current_membership_level_expiration varchar,
    store_id varchar,
    store_address varchar,
    store_city varchar,
    created_at varchar,
    updated_at varchar,
    wishlist_item varchar,
    time bigint
);