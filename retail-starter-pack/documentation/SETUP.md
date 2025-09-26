# Treasure Data Retail Starter Pack - Setup Guide

## Prerequisites

Before starting, ensure you have:
- ✅ Uploaded the retail-starter-pack to your Treasure Data project
- ✅ Basic familiarity with Treasure Data workflows and databases
- ✅ Access to your raw data tables in Treasure Data
- ✅ Admin permissions to create databases and run workflows

## Setup Overview

The setup process involves configuring three main components in order:

1. **`config/src_params.yml`** - Environment and database configuration
2. **`config/schema_map.yml`** - Data mapping between your source and target schemas  
3. **`prep/queries/{table_name}.sql`** - Custom preparation queries for data normalization

The Value Accelerator follows this automated pipeline:
```
Raw Data → Prep → Mapping → Validation → Staging → Unification → Golden Layer → Parent Segment
```

Each step requires specific configuration to match your data structure.


---

## Step 1: Configure src_params.yml

The `src_params.yml` file contains the core configuration for your retail data pipeline.

### 1.1 Database Configuration

Update the database names to match your naming conventions:

```yaml
## DATABASE CONFIG ##
raw: your_raw_database_prefix       # Where your raw data is stored
prp: your_prp_database_prefix       # Profile-Ready Processing database
src: your_src_database_prefix       # Source processed database
stg: your_staging_database_prefix   # Staging database
gld: your_golden_database_prefix    # Golden layer database
ana: your_analytics_database_prefix # Analytics database
sub: your_project_identifier        # Usually your customers name
```

**Example:**
```yaml
raw: raw
prp: prp
src: src
stg: stg
gld: gld
ana: ana
sub: brand_customer_name
```

### 1.2 Set Project Secrets

The retail starter pack requires a Treasure Data API key for various operations including unification, dashboard creation, and segment management.

#### Configure the API Key Secret:

1. In Treasure Data Console, navigate to your project
2. Go to **Workflows** → **Secrets**
3. Create the following secrets:

| Secret Name | Value | Usage |
|-------------|-------|-------|
| `td_apikey` | Your TD API Key | Used for unification, analytics, and segment creation |

**To get your API key:**
- Go to TD Console → Your Profile → API Keys
- Create a new API key or use existing master API Key 
- Copy the API key value

**Important:** Both `td_apikey` and should have the same value - some workflows use different naming conventions.

### 1.3 Project Configuration

Set your project-specific details:

```yaml
## WORKFLOW CONFIG ##
run_all: true                    # Set to false after initial setup
project_name: your-workflow-project-name

## INSTANCE CONFIG ##
site: us # Change to 'eu' if using EU instance
```

### 1.4 Email Notifications

Configure who receives workflow notifications by editing `config/email_ids.yml`:

```yaml
email_ids: ['your-email@company.com', 'team-alerts@company.com']
```

### 1.5 Analytics Configuration

Configure dashboard and analytics settings:

```yaml
## ANALYTICS CONFIG ##
create_dashboard: 'yes'          # Set to 'no' if you don't want dashboards
dashboards: ['sales_analytics', 'idu_dashboard', 'web_analytics']
dash_users_list: ['user1@company.com', 'user2@company.com']
```

---

## Step 2: Configure schema_map.yml

The `schema_map.yml` file maps your source data fields to the standardized retail schema. This is the most critical configuration step as it determines how your data flows through the entire pipeline.

### 2.1 Understanding the Mapping Configuration

Each table mapping follows this pattern:

```yaml
- columns:
  - prp: source_field_name        # Field name in your raw data (PRP layer)
    src: target_field_name        # Target field name in standardized schema  
    type: data_type               # Expected data type (varchar, bigint, double)
  - prp: null                     # No source field available
    src: target_field_name        # Create empty field in target schema
    type: varchar
  prp_table_name: table_name      # PRP table name, or "not exists" to skip PRP
  src_table_name: target_table    # Target table name in SRC database
```

### 2.2 Key Mapping Concepts

**PRP Processing Control**: 
- `prp_table_name: table_name` → Enables PRP processing with custom transformations
- `prp_table_name: "not exists"` → Skips PRP, data goes directly to mapping

**Field Mapping Logic**:
- Maps your raw data field names (`prp`) to standardized Value Accelerator field names (`src`)
- Creates missing fields as null values when source data doesn't have required fields
- Handles data type conversions automatically

**Processing Flow**:
```
Your Raw Table → [PRP Transformation] → Mapping (schema_map.yml) → SRC Table → Validation
```

### 2.3 Table-by-Table Configuration Guide

#### Customer Profile Data (loyalty_profile)

Map your customer/profile data to the loyalty_profile schema:

```yaml
- columns:
  - prp: external_id
    src: your_customer_id_field    # e.g., "customer_id", "user_id"
    type: varchar
  - prp: email
    src: your_email_field          # e.g., "email_address", "email"
    type: varchar
  - prp: phone_number
    src: your_phone_field          # e.g., "phone", "mobile_number"
    type: varchar
  - prp: first_name
    src: your_first_name_field
    type: varchar
  - prp: last_name
    src: your_last_name_field
    type: varchar
  # Add mappings for address, city, state, etc.
  prp_table_name: loyalty_profile
  src_table_name: your_customer_table_name
```

#### Transaction Data (order_digital_transactions)

Map your e-commerce transaction data:

```yaml
- columns:
  - prp: user_id
    src: your_customer_id_field
    type: varchar
  - prp: id
    src: your_order_id_field       # e.g., "order_number", "transaction_id"
    type: varchar
  - prp: created_at
    src: your_order_date_field     # e.g., "order_date", "purchase_date"
    type: varchar
  - prp: current_total_price
    src: your_total_amount_field   # e.g., "total", "amount"
    type: double
  # Map billing/shipping addresses, payment method, etc.
  prp_table_name: order_digital_transactions
  src_table_name: your_orders_table_name
```

#### Product/Line Item Data (order_details)

Map your order line item data:

```yaml
- columns:
  - prp: order_id
    src: your_order_id_field
    type: varchar
  - prp: product_id
    src: your_product_id_field
    type: varchar
  - prp: product_name
    src: your_product_name_field
    type: varchar
  - prp: quantity
    src: your_quantity_field
    type: bigint
  - prp: price
    src: your_line_total_field
    type: double
  prp_table_name: order_details
  src_table_name: your_order_items_table_name
```

#### Email Marketing Data (email_activity)

Map your email engagement data:

```yaml
- columns:
  - prp: datetime
    src: your_activity_date_field  # e.g., "sent_date", "activity_timestamp"
    type: varchar
  - prp: email
    src: your_email_field
    type: varchar
  - prp: metric_name
    src: your_activity_type_field  # e.g., "event_type", "action"
    type: varchar
  - prp: campaign_name
    src: your_campaign_field       # e.g., "campaign_name", "message_name"
    type: varchar
  prp_table_name: email_activity
  src_table_name: your_email_events_table_name
```

### 2.4 Required vs Optional Tables

#### Required Tables (Must Configure):
- `loyalty_profile` - Customer/user profiles
- `order_digital_transactions` - Online transactions
- `order_details` - Order line items

#### Optional Tables (Configure if Available):
- `email_activity` - Email marketing data
- `pageviews` - Website analytics
- `app_analytics` - Mobile app data
- `consents` - Consent/preference data
- `formfills` - Form submission data
- `sms_activity` - SMS marketing data
- `survey_responses` - Survey/feedback data
- `order_offline_transactions` - In-store transactions

### 2.5 Common Mapping Patterns

#### When Your Field Names Match Standard Names:
```yaml
- prp: email
  src: email        # Same name
  type: varchar
```

#### When You Don't Have a Field:
```yaml
- prp: null         # Field doesn't in exist in PRP
  src: standard_schema_field
  type: varchar
```

#### When You Need to Rename Fields:
```yaml
- prp: user_id      # Your field name
  src: customer_id  # Standard name
  type: varchar
```

---

## Step 3: Configure PRP Queries

The PRP (Prep) layer allows you to create custom SQL queries to transform complex data before schema mapping. This is only needed when your raw data requires preprocessing like JSON parsing, field concatenation, or record deduplication.

### 3.1 When to Use PRP Queries

For tables with `prp_table_name` set (not "not exists"), the workflow executes custom transformation queries:

```yaml
# In wf02_mapping.dig, this step runs:
+prep: 
  td>: prep/queries/${tbl.src_table_name}.sql
  database: ${raw}_${sub}
```

This means for each table with PRP enabled, you can create a corresponding SQL file in `prep/queries/` to transform your raw data.

### 3.2 Creating PRP Query Files

Create SQL files in the `prep/queries/` directory with the same name as your source table:

```
prep/
└── queries/
    ├── app_analytics.sql        # For app_analytics table
    ├── email_activity.sql       # For email_activity table
    ├── loyalty_profile.sql      # For loyalty_profile table
    ├── order_details.sql        # For order_details table
    └── survey_responses.sql     # For survey_responses table
```

### 3.3 JSON Field Transformation Examples

#### Example 1: App Analytics with JSON Event Properties

If your `app_analytics` table has JSON fields for `event_properties` and `user_properties`:

**File: `prep/queries/app_analytics.sql`**
```sql
-- Transform app analytics data with JSON parsing
SELECT 
  app_name,
  analytics_id,
  user_id,
  email,
  phone_number,
  device_id,
  event_time,
  event_type,
  platform,
  
  -- Parse JSON event_properties
  JSON_EXTRACT_SCALAR(event_properties, '$.product_id') as event_product_id,
  JSON_EXTRACT_SCALAR(event_properties, '$.category') as event_category,
  JSON_EXTRACT_SCALAR(event_properties, '$.revenue') as event_revenue,
  JSON_EXTRACT_SCALAR(event_properties, '$.currency') as event_currency,
  
  -- Parse JSON user_properties  
  JSON_EXTRACT_SCALAR(user_properties, '$.subscription_tier') as user_tier,
  JSON_EXTRACT_SCALAR(user_properties, '$.registration_date') as user_reg_date,
  JSON_EXTRACT_SCALAR(user_properties, '$.preferred_language') as user_language,
  
  -- Keep original JSON for reference
  event_properties,
  user_properties,
  
  time
FROM ${raw}_${sub}.app_analytics_tmp
WHERE time >= {{ moment(session_time).subtract(1, 'day').unix() }}
```

#### Example 2: E-commerce Order Data with Nested JSON

**File: `prep/queries/order_digital_transactions.sql`**
```sql
-- Transform order data with JSON address parsing
SELECT 
  customer_id,
  email,
  phone_number,
  order_no,
  order_datetime,
  amount,
  
  -- Parse JSON billing_address if stored as JSON
  CASE 
    WHEN billing_address LIKE '{%}' THEN JSON_EXTRACT_SCALAR(billing_address, '$.street')
    ELSE billing_address 
  END as billing_address_street,
  
  CASE 
    WHEN billing_address LIKE '{%}' THEN JSON_EXTRACT_SCALAR(billing_address, '$.city')
    ELSE billing_city 
  END as billing_city_parsed,
  
  CASE 
    WHEN billing_address LIKE '{%}' THEN JSON_EXTRACT_SCALAR(billing_address, '$.state')
    ELSE billing_state 
  END as billing_state_parsed,
  
  -- Parse payment_details JSON
  JSON_EXTRACT_SCALAR(payment_details, '$.method') as payment_method_parsed,
  JSON_EXTRACT_SCALAR(payment_details, '$.last4') as payment_last4,
  JSON_EXTRACT_SCALAR(payment_details, '$.brand') as payment_brand,
  
  -- Original fields
  billing_address,
  payment_details,
  time
  
FROM ${raw}_${sub}.order_digital_transactions_tmp
WHERE time >= {{ moment(session_time).subtract(1, 'day').unix() }}
```

#### Example 3: Survey Responses with Dynamic Questions

**File: `prep/queries/survey_responses.sql`**
```sql
-- Transform survey data with JSON response parsing
SELECT 
  survey_id,
  respondent_id,
  customer_id,
  email,
  phone_number,
  submitted_at,
  
  -- Parse survey_data JSON to extract specific questions
  JSON_EXTRACT_SCALAR(survey_data, '$.nps_score') as nps_score,
  JSON_EXTRACT_SCALAR(survey_data, '$.satisfaction_rating') as satisfaction_rating,
  JSON_EXTRACT_SCALAR(survey_data, '$.recommendation_likelihood') as recommendation_likelihood,
  JSON_EXTRACT_SCALAR(survey_data, '$.product_feedback') as product_feedback,
  JSON_EXTRACT_SCALAR(survey_data, '$.service_rating') as service_rating,
  
  -- Extract demographic info from JSON
  JSON_EXTRACT_SCALAR(demographic_data, '$.age_range') as age_range,
  JSON_EXTRACT_SCALAR(demographic_data, '$.income_range') as income_range,
  JSON_EXTRACT_SCALAR(demographic_data, '$.location') as location,
  
  -- Keep original JSON
  survey_data,
  demographic_data,
  time
  
FROM ${raw}_${sub}.survey_responses_tmp  
WHERE time >= {{ moment(session_time).subtract(1, 'day').unix() }}
```

### 3.4 Advanced JSON Transformation Techniques

#### Flattening Array Fields
```sql
-- For JSON arrays, use UNNEST to create multiple rows
SELECT 
  customer_id,
  email,
  order_no,
  JSON_EXTRACT_SCALAR(item, '$.product_id') as product_id,
  JSON_EXTRACT_SCALAR(item, '$.quantity') as quantity,
  JSON_EXTRACT_SCALAR(item, '$.price') as price,
  time
FROM ${raw}_${sub}.orders_tmp
CROSS JOIN UNNEST(JSON_EXTRACT_ARRAY(line_items)) AS t(item)
WHERE time >= {{ moment(session_time).subtract(1, 'day').unix() }}
```

#### Conditional JSON Parsing
```sql
-- Handle different JSON structures conditionally
SELECT 
  customer_id,
  email,
  
  -- Handle different event_data formats
  CASE 
    WHEN JSON_EXTRACT_SCALAR(event_data, '$.version') = 'v2' THEN 
      JSON_EXTRACT_SCALAR(event_data, '$.data.product_id')
    WHEN JSON_EXTRACT_SCALAR(event_data, '$.version') = 'v1' THEN 
      JSON_EXTRACT_SCALAR(event_data, '$.product_id')
    ELSE NULL
  END as product_id,
  
  event_data,
  time
FROM ${raw}_${sub}.events_tmp
WHERE time >= {{ moment(session_time).subtract(1, 'day').unix() }}
```

### 3.5 Updating Schema Map for PRP-Transformed Fields

After creating PRP queries, update your `schema_map.yml` to map the transformed fields:

```yaml
- columns:
  # Map the parsed JSON fields from PRP
  - prp: event_product_id
    src: event_product_id        # From your PRP query
    type: varchar
  - prp: event_revenue
    src: event_revenue           # From your PRP query  
    type: double
  - prp: user_tier
    src: user_tier               # From your PRP query
    type: varchar
  
  # Keep original JSON if needed
  - prp: null
    src: event_properties        # Original JSON field
    type: varchar
    
  prp_table_name: app_analytics
  src_table_name: app_analytics
```

### 3.6 Time-based Incremental Processing

Include time-based filtering in your PRP queries for incremental processing:

```sql
-- Standard time filter for incremental processing
WHERE time >= {{ moment(session_time).subtract(1, 'day').unix() }}

-- Or for specific date ranges
WHERE DATE(time_column) >= DATE('{{ session_date }}') - INTERVAL '1' DAY
```

### 3.7 Data Quality Validation in PRP

Add data quality checks to your PRP queries:

```sql
SELECT 
  customer_id,
  email,
  
  -- Validate and clean email
  CASE 
    WHEN email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN email
    ELSE NULL 
  END as clean_email,
  
  -- Validate JSON before parsing
  CASE 
    WHEN JSON_VALID(event_properties) THEN 
      JSON_EXTRACT_SCALAR(event_properties, '$.product_id')
    ELSE NULL 
  END as product_id,
  
  time
FROM ${raw}_${sub}.events_tmp
WHERE time >= {{ moment(session_time).subtract(1, 'day').unix() }}
  AND customer_id IS NOT NULL  -- Basic data quality filter
```

### 3.8 Testing PRP Queries

Before running the full workflow, test your PRP queries:

```sql
-- Test query execution
SELECT COUNT(*) as row_count 
FROM (
  -- Your PRP query here
  SELECT * FROM ${raw}_${sub}.your_table_tmp
  WHERE time >= {{ moment(session_time).subtract(1, 'day').unix() }}
) subquery;

-- Test JSON parsing
SELECT 
  COUNT(*) as total_rows,
  COUNT(JSON_EXTRACT_SCALAR(json_field, '$.key')) as parsed_rows,
  COUNT(*) - COUNT(JSON_EXTRACT_SCALAR(json_field, '$.key')) as unparsed_rows
FROM ${raw}_${sub}.your_table_tmp;
```

### 3.9 Common JSON Functions in Treasure Data

| Function | Purpose | Example |
|----------|---------|---------|
| `JSON_EXTRACT_SCALAR(json, path)` | Extract scalar value | `JSON_EXTRACT_SCALAR(data, '$.name')` |
| `JSON_EXTRACT_ARRAY(json, path)` | Extract array | `JSON_EXTRACT_ARRAY(data, '$.items')` |
| `JSON_EXTRACT(json, path)` | Extract JSON object | `JSON_EXTRACT(data, '$.address')` |
| `JSON_VALID(json)` | Validate JSON format | `JSON_VALID(json_string)` |
| `JSON_SIZE(json, path)` | Get array/object size | `JSON_SIZE(data, '$.items')` |

---

## Step 4: Development and Testing

### 4.1 Validate Your Configuration

Before running the full pipeline, validate your configuration:

```sql
-- Check if your raw data tables exist
SELECT table_name, row_count 
FROM INFORMATION_SCHEMA.TABLES 
WHERE schema_name = 'your_raw_database_name';

-- Verify required fields exist in your source tables
DESCRIBE your_raw_database.loyalty_profile;
DESCRIBE your_raw_database.order_digital_transactions;
```

### 4.2 Test with Mapping Workflow

Start with prep and mapping to test prep queries and mapping:

```bash
# Test configuration without full processing locally
td workflow run wf02_mapping

# Test configuration without full processing in TD instance
td workflow start your-project-name wf02_mapping --session now  
```


### 4.3 Development Approach

**Recommended development sequence:**

1. **Configure Core Tables First**: Start with `loyalty_profile` and `order_digital_transactions`
2. **Test Mapping**: Run mapping workflow after each table configuration
3. **Add PRP Queries**: Only if needed if required columns are not readily availalbe in raw/prp without normalization
4. **Iterative Testing**: Test each component/table before moving to the next

### 4.4 Validation 
After prep and mapping are completed proceed with the validation step. 

```bash
# Test configuration without full processing locally 
# Requires Docker to be running
td wf secrets --local --set td_apikey=your_secret_value 
td workflow run wf03_validate

# Test configuration without full processing in TD instance
td workflow start your-project-name wf03_validate --session now  
```


### 4.5 Full Pipeline Testing

Once validation passes, test the complete pipeline:

```bash
# Run the full orchestration workflow locally
td workflow run your-project-name wf00_orchestration 

# Run the full orchestration workflow in TD Instance
td workflow start your-project-name wf00_orchestration --session now  
```

**Monitor execution:**
- Check workflow status in TD Console → Workflows
- Verify databases are created: `prp_`, `src_`, `stg_`, `gld_`, `ana_`
- Review email notifications for any issues
- Check logs for each workflow step

---

## Step 5: Deployment and Production

### 5.1 Environment Configuration

For production deployment:

1. **Configure scheduling**: Set up regular workflow schedules in TD Console
2. **Verify email notifications**: Ensure alerts go to appropriate teams

### 5.2 Production Deployment Checklist

- [ ] All required raw data tables are populated
- [ ] Schema mapping validated in development environment
- [ ] PRP queries tested (if used)
- [ ] Email notification lists configured
- [ ] Workflow schedules configured
- [ ] Success/failure monitoring in place

### 5.3 Post-Deployment Verification

After successful deployment, verify the complete pipeline:

```sql
-- Check data flow through all layers
SELECT 'raw' as layer, COUNT(*) FROM your_raw_db.loyalty_profile
UNION ALL
SELECT 'staging' as layer, COUNT(*) FROM stg_customer.loyalty_profile  
UNION ALL
SELECT 'golden' as layer, COUNT(*) FROM gld_customer.loyalty_profile;

-- Verify unification results
SELECT COUNT(DISTINCT canonical_customer_id) as unified_customers
FROM gld_customer.loyalty_profile;

-- Check parent segment creation
SELECT audience_id, name, status 
FROM va_config_customer.parent_segment_creation;
```

### 5.4 Analytics and Segmentation Access

After successful setup:
- **Audience Studio**: Access unified customer data for segmentation
- **Treasure Insights**: View auto-generated dashboards (if enabled)
- **Customer Segments**: Available in TD Audience Studio for activation

---

## Troubleshooting

### Common Issues and Solutions

#### Issue: "Table not found" errors
**Solution:** 
- Verify table names in `schema_map.yml` match your raw data tables exactly
- Check database name in `src_params.yml` is correct
- Ensure tables exist in specified prp database

#### Issue: "Column not found" errors  
**Solution:**
- Check column names in `schema_map.yml` match your source data exactly
- Use `INFORMATION_SCHEMA.TABLES` to verify column names
- Set `prp: null` for columns you don't have

#### Issue: Data type mismatches
**Solution:**
- Review validation reports for type mismatches
- Update `type` field in `schema_map.yml` to match actual data types
- Consider data transformations if needed

### Getting Help

If you encounter issues:
1. **Check Logs**: Review workflow execution logs in TD console
2. **Email Reports**: Check validation reports sent to configured emails  
3. **Data Quality**: Run the validation queries above
4. **Configuration**: Double-check field mappings in `schema_map.yml`
5. **Support**: Contact your Treasure Data support team with specific error messages

---
