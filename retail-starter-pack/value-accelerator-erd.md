erDiagram
    LOYALTY_PROFILE {
        varchar customer_id PK
        varchar email
        varchar secondary_email
        varchar phone_number
        varchar first_name
        varchar last_name
        varchar address
        varchar country
        varchar city
        varchar state
        varchar postal_code
        varchar gender
        varchar date_of_birth
        varchar membership_status
        varchar membership_tier
        double net_redeemable_balance
        double net_debits
        bigint membership_points_earned
        bigint membership_points_balance
        bigint membership_points_pending
        bigint total_loyalty_purchases
        varchar current_membership_level_expiration
        varchar store_id
        varchar store_address
        varchar store_city
        varchar created_at
        varchar updated_at
        varchar wishlist_item
        bigint time
    }

    ORDER_DIGITAL_TRANSACTIONS {
        varchar customer_id FK
        varchar email
        varchar phone_number
        varchar token
        varchar order_no PK
        varchar order_datetime
        varchar payment_method
        varchar promo_code
        varchar projected_delivery_date
        varchar bopis_flag
        varchar location_id
        varchar location_address
        varchar location_city
        varchar location_state
        varchar location_postal_code
        varchar location_country
        varchar markdown_flag
        varchar guest_checkout_flag
        varchar order_transaction_type
        double amount
        double discount_amount
        double net_amount
        bigint shipping_cost
        varchar expidated_ship_flag
        varchar billing_address
        varchar billing_city
        varchar billing_state
        varchar billing_postal_code
        varchar billing_country
        varchar shipping_address
        varchar shipping_city
        varchar shipping_state
        varchar shipping_postal_code
        varchar shipping_country
        bigint time
    }

    ORDER_OFFLINE_TRANSACTIONS {
        varchar email
        varchar phone_number
        varchar order_no PK
        varchar order_datetime
        varchar payment_method
        varchar promo_code
        varchar markdown_flag
        varchar store_address
        varchar store_postal_code
        varchar store_city
        varchar store_state
        varchar store_country
        bigint time
    }

    ORDER_DETAILS {
        varchar order_no FK
        varchar order_transaction_type
        bigint quantity
        varchar product_id
        varchar product_color
        varchar product_name
        varchar product_size
        varchar product_description
        varchar product_department
        varchar product_sub_department
        double list_price
        double discount_offered
        double tax
        double net_price
        bigint order_line_no PK
        bigint time
    }

    EMAIL_ACTIVITY {
        varchar activity_date
        varchar campaign_id
        varchar campaign_name
        varchar email FK
        varchar customer_id FK
        varchar activity_type
        bigint time
    }

    SMS_ACTIVITY {
        varchar phone_number FK
        varchar email FK
        varchar activity_type
        varchar message_type
        varchar message_name
        varchar message_text
        varchar message_link
        varchar message_creative
        bigint time
    }

    PAGEVIEWS {
        varchar td_url
        varchar td_path
        varchar td_title
        varchar td_description
        varchar td_host
        varchar td_language
        varchar td_charset
        varchar td_os
        varchar td_os_version
        varchar td_user_agent
        varchar td_platform
        varchar td_screen
        varchar td_viewport
        varchar td_color
        varchar td_version
        varchar td_global_id PK
        varchar td_client_id
        varchar td_ip
        varchar td_referrer
        varchar td_browser
        varchar td_browser_version
        bigint time
    }

    FORMFILLS {
        varchar email FK
        varchar phone_number FK
        varchar td_global_id
        varchar td_client_id FK
        varchar form_type
        bigint time
    }

    SURVEY_RESPONSES {
        varchar email FK
        varchar phone_number FK
        bigint time
    }

    CONSENTS {
        varchar id PK
        varchar id_type
        varchar consent_type
        varchar consent_flag
        bigint time
    }

    INVALID_EMAILS {
        varchar invalid_email PK
    }

    %% Relationships
    LOYALTY_PROFILE ||--o{ ORDER_DIGITAL_TRANSACTIONS : customer_id
    LOYALTY_PROFILE ||--o{ EMAIL_ACTIVITY : customer_id
    LOYALTY_PROFILE ||--o{ EMAIL_ACTIVITY : email
    LOYALTY_PROFILE ||--o{ SMS_ACTIVITY : phone_number
    LOYALTY_PROFILE ||--o{ SMS_ACTIVITY : email
    LOYALTY_PROFILE ||--o{ FORMFILLS : email
    LOYALTY_PROFILE ||--o{ FORMFILLS : phone_number
    LOYALTY_PROFILE ||--o{ SURVEY_RESPONSES : email
    LOYALTY_PROFILE ||--o{ SURVEY_RESPONSES : phone_number
    
    ORDER_DIGITAL_TRANSACTIONS ||--o{ ORDER_DETAILS : order_no
    ORDER_OFFLINE_TRANSACTIONS ||--o{ ORDER_DETAILS : order_no
    
    PAGEVIEWS ||--o{ FORMFILLS : td_client_id
    
    CONSENTS ||--o{ LOYALTY_PROFILE : id_email_phone
    INVALID_EMAILS ||--o{ EMAIL_ACTIVITY : email validation
    INVALID_EMAILS ||--o{ LOYALTY_PROFILE : email validation
    INVALID_EMAILS ||--o{ FORMFILLS : email validation
