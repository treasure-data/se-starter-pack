# Treasure Data Value Accelerator - Retail Starter Pack

## Treasure Data Value Accelerator Overview

The CDP collects, cleanses, unifies, segments, and activates data to enhance customer experiences. Treasure Data provides an Out-of-the-Box template to orchestrate all the necessary tasks to make data accessible for segmentation & activation. The data flow through Treasure Data to achieve this is:

There are six main stages to the data flow through the CDP:

### Data Flow Stages

1. **Ingestion** - Batch/Streaming
2. **Data Validation & Transformation** - Data orchestration for Parent Segment Creation
3. **Unification** - Single Customer View [GLD]
4. **Parent Segment Creation**
5. **Segmentation & Activation** - Ad-hoc/Scheduled

## Ingestion

Ingestion is performed using standard Treasure Data connectors or SDKs to land data from source systems into the Treasure Data landing database (SRC database). Data is inserted to the SRC database tables as-is from the source with no transformations. Depending on the source the data may be loaded either via batch on a scheduled basis or streamed in near real-time.

### PRP (Profile-Ready Processing) Layer

The retail starter pack includes a PRP layer that sits between raw data ingestion and the source schema. PRP provides:
- Initial data standardization
- Column mapping and type conversion
- Early filtering of unnecessary fields
- Preparation for downstream profile unification

For further details, and specific details on the schema required see Data Ingestion.

## Data Validation & Transformation

Data validation & transformation is the first stage of the scheduled data orchestration that builds the Parent Segment.

In this step the data ingested to the landing database (SRC database) is validated to ensure schema requirements are met and then loaded by Treasure Data workflows to the staging repository database (STG database), as a 1:1 copy of data from the source system, with some row-level data cleansing and persistent derivations applied (e.g. flags to indicate the validity of an email address format). (More complex attribute derivations are deferred to the GLD Stage – see GLD section.)

### PRP Processing Flow
For tables with PRP enabled:
1. Raw data flows into the PRP database
2. PRP transformations are applied based on schema_map.yml configurations
3. Processed data moves to the SRC database
4. Standard validation and staging processes continue

## Unification

Unification is the second stage of the scheduled data orchestration that builds the Parent Segment.

Unification is the process of consolidating parties in the source systems to an audience level at which the CDP manages engagement via a Parent Segment. In the Retail Value Accelerator, the source parties are:
- Web visitors identified by cookies
- Customers (former, current & pending) identified by customer ID, email, or phone number
- Transactions from various sources (digital, in-store sales) identified by email, phone number, customer ID or credit card token
- App users identified by analytics IDs and device identifiers
- Survey respondents and SMS recipients

The audience level for the Parent Segment is at an individual person level.

The unification is performed using known relationships held in the source system (such as relationships between emails and customer IDs) and rules for matching using personal data (such as email addresses and phone numbers). Unification assigns a canonical ID as an identifier for the unified individual and creates an identity graph that maps the source identifiers (cookies, customer IDs, emails, phone numbers, device IDs, and credit card tokens) to the canonical ID.

Unification allows the CDP to have a holistic view of an individual, even if that person is identified by different identifiers in the source system.

## Single Customer View [GLD]

Creation of the single customer view is the third stage of the orchestration that builds the Parent Segment.

In this step the data is mapped from the source database operational schema into a schema optimized for the Parent Segment. This involves:
- Mapping source entities into Master, Attribute and Behaviour tables that can be mapped into a Parent Segment
- Performing more complex derivations and data cleansing
- Aggregating source records for an individual and deriving the best values of attributes for that individual as well as aggregate metrics such as Lifetime Value and Average Order Value

## Parent Segment Creation

This is the final stage of the orchestration that builds the Parent Segment, which is the audience within Treasure Data that is made available to users for the creation of segments etc. within the Audience Studio.

In this step the single customer view tables from the GLD database are mapped into the Parent Segment, and the Audience Studio's Parent Segment build is performed. Additionally, certain base segments are created such as High Lifetime Value customers.

## Segmentation & Activation

Segmentation and activation are tasks that can be performed and scheduled by users within a Parent Segment to select a subset of individuals for which data is made available to other systems to deliver Customer Experience Use Cases.

# Data Ingestion

## Required Tables

The following tables and associated columns are required for the value accelerator to run without failure.

### Special Considerations:
- Any of the fields can be empty but the table and column must exist in the database
- Values in each column, except dates which are required to be in ISO8601 format, can be in any format but the preferred format is indicated in the notes sections by Italics
- Additional columns and tables can be included in the source database without issues however additional work is required to make this data available in the Parent Segment for segmentation
- Tables marked with PRP processing will undergo initial transformations before entering the main pipeline

### Loyalty Profile

The Profile Table is the central repository of customer information, aggregated from various interactions and transactions typically originating from a CRM/Loyalty system

| Column | Type | Description |
|--------|------|-------------|
| customer_id | string | Unique Customer ID |
| email | string | Email Address |
| secondary_email | string | Secondary Email Address |
| phone_number | string | Phone Number |
| first_name | string | First Name |
| last_name | string | Last Name |
| address | string | Address |
| city | string | City |
| state | string | State |
| postal_code | string | Postal Code |
| country | string | Country |
| gender | string | Gender |
| date_of_birth | string | ISO8601 Date - Date Of Birth (1990-02-08) |
| favourite_location_names | string | Comma-separated list of location names selected by profile |
| membership_status | string | Current status of Membership Status (Active, Lapsed etc) |
| membership_level | string | Membership tier/level |
| membership_points_balance | double | Current points balance |
| membership_points_earned | double | Total lifetime points earned |
| membership_points_pending | double | Pending points |
| total_loyalty_purchases | int | Number of Purchases made with Loyalty Profile |
| current_membership_level_expiration | string | ISO8601 Date - Date current membership tier/level expires |
| wishlist_items | string | Comma-separated list of wishlist items |
| preferred_store_id | string | Preferred store location ID |
| preferred_store_name | string | Preferred store location name |
| preferred_store_address | string | Preferred store address |
| preferred_store_city | string | Preferred store city |
| preferred_store_state | string | Preferred store state |
| preferred_store_postal_code | string | Preferred store postal code |
| preferred_store_country | string | Preferred store country |
| updated_at | string | ISO8601 Date - Profile Last Updated At Timestamp |
| created_at | string | ISO8601 Date - Profile Create At Timestamp |

### Consents

The Consents Table contains the record of customer permissions regarding customer communication. Consent is managed at the identifier level such as email or phone number.

| Column | Type | Description |
|--------|------|-------------|
| id | string | ID Field can contain mix of emails and phone numbers |
| id_type | string | Type of identifier (email or phone number, etc) |
| consent_type | string | Field indicates if consent is for a specific purpose |
| consent_flag | string | Boolean signaling consent status of a marketable identifier |

### Email Activity

The Email Activity table is the record of all engagement a customer has with email, keeping track of email opens, clicks, etc.

| Column | Type | Description |
|--------|------|-------------|
| activity_date | string | ISO8601 Timestamp of interaction |
| campaign_id | string | Campaign ID associated with Email Activity |
| campaign_name | string | Campaign Name associated with Email Name |
| email | string | Email Address |
| customer_id | string | Customer ID |
| activity_type | string | Activity Type (email_opened, email_sent, email_clicked, email_hardbounced, email_softbounced) |

### SMS Activity

The SMS Activity table records all SMS marketing interactions and engagement.

| Column | Type | Description |
|--------|------|-------------|
| phone_number | string | Phone Number |
| email | string | Email Address |
| activity_type | string | SMS Activity Type |
| message_type | string | Type of message |
| message_name | string | Name of message/campaign |
| message_text | string | Text content of message |
| message_link | string | Link included in message |
| message_creative | string | Creative/template used |
| message_date | string | ISO8601 Date of message |

### Pageviews

The pageviews table is populated by the successful deployment of the Treasure Data JS SDK.

For documentation on deploying the SDK tag please visit: https://docs.treasuredata.com/articles/#!pd/working-with-the-js-sdk

| Column | Type | Description |
|--------|------|-------------|
| td_global_id | string | Treasure Data's 3rd Party Cookie |
| td_version | string | Version of Treasure Data's JS SDK |
| td_client_id | string | Treasure Data's 1st Party Cookie |
| td_charset | string | Browser Charset |
| td_language | string | Browser Language |
| td_color | string | Browser Color |
| td_screen | string | Browser Screensize |
| td_viewport | string | Browser Viewport Size |
| td_title | string | Title of Page |
| td_description | string | Description of Page |
| td_url | string | URL of Page |
| td_user_agent | string | Browser User Agent |
| td_platform | string | Browser Platform |
| td_host | string | Host of Page |
| td_path | string | Path of Page |
| td_referrer | string | Referring source of the page |
| td_ip | string | Browser IP Address |
| td_browser | string | Browser Type |
| td_browser_version | string | Browser Version |
| td_os | string | Browser OS |
| td_os_version | string | Browser OS Version |

### App Analytics

The app analytics table includes analytics data from any mobile App associated with your brand.

| Column | Type | Description |
|--------|------|-------------|
| app_name | string | Name of the mobile app |
| analytics_id | string | ID generated by analytics platform |
| analytics_user_id | string | Analytics platform user ID |
| user_id | string | App user ID |
| customer_id | string | Unique Customer ID |
| email | string | Email Address |
| phone_number | string | Phone Number |
| device_id | string | Device identifier |
| event_type | string | Type of Event Record |
| event_time | string | ISO8601 timestamp of app interaction |
| event_properties | string (JSON) | Customer properties added to event - JSON will be dynamically unpacked |
| user_properties | string (JSON) | User properties - JSON will be dynamically unpacked |
| idfa | string | IDFA ID |
| adid | string | Android ID |
| platform | string | Device platform (iOS, Android) |
| app_version | string | Version of the app |
| device_brand | string | Device manufacturer |
| device_model | string | Device model |
| device_type | string | Type of device |
| os_name | string | Operating system name |
| os_version | string | Operating system version |
| country | string | User country |
| region | string | User region |
| city | string | User city |
| location_lat | double | Location latitude |
| location_lng | double | Location longitude |

### Order Digital Transactions

The digital transactions table should contain all records of purchases made in the App. Line Items for each transaction should appear in the Order Details table.

| Column | Type | Description |
|--------|------|-------------|
| customer_id | string | Unique Customer ID |
| email | string | Email Address |
| phone_number | string | Phone Number |
| token | string | Credit Card Token |
| order_no | string | Order Identifier |
| order_datetime | string | ISO8601 timestamp of transaction |
| payment_method | string | Payment method used for transaction |
| weather | string | Weather when the transaction was made |
| location_id | string | ID of the Location where transaction happened |
| location_address | string | Address of the location where transaction happened |
| location_name | string | Name of the location where transaction happened |
| location_city | string | City of the location where transaction happened |
| location_state | string | State of the location where transaction happened |
| location_postal_code | string | Postal Code of the location where transaction happened |
| location_country | string | Country of the location where transaction happened |
| amount | double | Transaction Amount |
| discount_amount | double | Total discount applied |
| tax_amount | double | Total tax amount |
| tip_amount | double | Tip amount |
| promo_flag | string | Flag indicating any promotion offer/discount was used ('True'/'1', 'False'/'0') |
| markdown_flag | string | Flag indicating there were markdown/sales items included ('True'/'1', 'False'/'0') |
| guest_checkout_flag | string | Flag indicating the transaction happened in guest mode ('True'/'1', 'False'/'0') |
| bopis_flag | string | Buy Online Pick-up In Store flag ('True'/'1', 'False'/'0') |
| delivery_type | string | Type of delivery (Standard, Express, etc) |
| delivery_date | string | ISO8601 Date of delivery |
| billing_address | string | Billing address |
| billing_city | string | Billing city |
| billing_state | string | Billing state |
| billing_postal_code | string | Billing postal code |
| billing_country | string | Billing country |
| shipping_address | string | Shipping address |
| shipping_city | string | Shipping city |
| shipping_state | string | Shipping state |
| shipping_postal_code | string | Shipping postal code |
| shipping_country | string | Shipping country |

### Order Offline Transactions

The offline transactions table should contain all records of in-store purchases.

| Column | Type | Description |
|--------|------|-------------|
| customer_id | string | Unique Customer ID |
| email | string | Email Address |
| phone_number | string | Phone Number |
| token | string | Credit Card Token |
| order_no | string | Order Identifier |
| order_datetime | string | ISO8601 timestamp of transaction |
| payment_method | string | Payment method used for transaction |
| weather | string | Weather when the transaction was made |
| location_id | string | ID of the Location where transaction happened |
| location_address | string | Address of the location where transaction happened |
| location_name | string | Name of the location where transaction happened |
| location_city | string | City of the location where transaction happened |
| location_state | string | State of the location where transaction happened |
| location_postal_code | string | Postal Code of the location where transaction happened |
| location_country | string | Country of the location where transaction happened |
| amount | double | Transaction Amount |
| promo_flag | string | Flag indicating any promotion offer/discount was used ('True'/'1', 'False'/'0') |
| markdown_flag | string | Flag indicating there were markdown/sales items included ('True'/'1', 'False'/'0') |

### Order Details

This table details each line item of each transaction describing each product that was purchased, its price, quantity etc.

| Column | Type | Description |
|--------|------|-------------|
| order_no | string | Order Identifier |
| order_line_no | string | Line Item # |
| order_transaction_type | string | Type of transaction line item is associated with (Digital, Offline, etc) |
| quantity | double | Number of Products Purchase for Line Item |
| list_price | double | Total List/Retail Price of Line Item |
| discount_offered | double | Total Discount Amount of Line Item |
| tax | double | Total Tax Amount of Line Item |
| net_price | double | Total Net Price of Line Item |
| product_id | string | Product ID of Product Purchased |
| product_size | string | Product Size of Product Purchased |
| product_color | string | Product Color of Product Purchased |
| product_name | string | Product Name of Product Purchased |
| product_description | string | Product Description of Product Purchased |
| product_department | string | Product Department/Category of Product Purchased |
| product_sub_department | string | Product Sub Department/Sub Category of Product Purchased |

### Formfills

The form fills table will also be populated by Treasure Data's SDK. When customers log in or provide PII, the SDK will be configured to send over identifiable information like email or phone number to create a mapping between the 1st party cookie and PII to turn anonymous browsers into known profiles.

| Column | Type | Description |
|--------|------|-------------|
| email | string | Email Address |
| phone_number | string | Phone Number |
| td_global_id | string | Treasure Data's 3rd Party Cookie |
| td_client_id | string | Treasure Data's 1st Party Cookie |
| form_type | string | Type of Form Completed (Account Signup, Newsletter etc) |

### Survey Responses

The survey responses table captures customer feedback and survey data.

| Column | Type | Description |
|--------|------|-------------|
| survey_id | string | Unique survey identifier |
| respondent_id | string | Unique respondent identifier |
| question_id | string | Question identifier |
| question_text | string | Text of the question |
| answer | string | Text answer provided |
| answer_numeric | double | Numeric answer (for rating questions) |
| customer_id | string | Customer ID if known |
| email | string | Email address |
| phone_number | string | Phone number |
| submission_date | string | ISO8601 Date of submission |

## ERD

The Entity Relationship Diagram shows how all tables connect through various identifiers to create a unified customer view. Key relationships include:

- **Customer Identity Hub**: `customer_id`, `email`, `phone_number` serve as primary linking fields
- **Transaction Linking**: Orders connect through `order_no` to order details
- **Web/App Tracking**: Cookies (`td_client_id`, `td_global_id`) link anonymous behavior to known profiles via formfills
- **Consent Management**: Linked via `id` field (email/phone) to ensure proper communication preferences
- **PRP Layer**: Tables with PRP processing undergo initial transformation before standard processing

## Data Validation & Transformation

The retail starter pack includes comprehensive validation queries that:
1. Check for required columns in each table
2. Validate data types match expectations
3. Report missing critical fields
4. Generate warnings for data quality issues
5. Apply PRP transformations where configured

Validation results are logged and can trigger email notifications for critical issues.