# Treasure Data Retail Starter Pack - Setup Guide

## Prerequisites

Before starting, ensure you have:
- ✅ Uploaded the retail-starter-pack to your Treasure Data project
- ✅ Basic familiarity with Treasure Data workflows and databases
- ✅ Access to your raw data tables in Treasure Data
- ✅ Admin permissions to create databases and run workflows

## Setup Overview

The setup process involves configuring two main files:
1. **`config/src_params.yml`** - Main configuration parameters
2. **`config/schema_map.yml`** - Data mapping between your source and target schemas

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

The `schema_map.yml` file maps your source data fields to the standardized retail schema. This is the most critical configuration step.

### 2.1 Understanding the Schema Map Structure

Each table mapping follows this pattern:

```yaml
- columns:
  - prp: target_field_name        # Field name in PRP/processed schema
    src: your_source_field_name   # Field name in your raw data
    type: data_type               # Expected data type
  - prp: null                     # Set to null if field not needed in PRP
    src: your_field_name
    type: varchar
  prp_table_name: table_name      # Name for PRP table, or "not exists" to skip PRP
  src_table_name: source_table    # Your source table name
```

### 2.2 Key Configuration Concepts

**PRP Processing**: Tables with `prp_table_name: not exists` skip PRP processing and go directly to source processing.

**Field Mapping**: Each column maps your source field to the standardized field name used by the retail accelerator.

**Null Fields**: Use `prp: null` for fields you want to ignore in PRP but keep in source processing.

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

## Step 2.6: Setting Up PRP Queries for JSON Field Transformation

The Profile-Ready Processing (PRP) layer allows you to create custom SQL queries to transform complex data, particularly JSON fields, before they enter the main processing pipeline.

### 2.6.1 Understanding PRP Query Execution

For tables with `prp_table_name` set (not "not exists"), the workflow executes custom transformation queries:

```yaml
# In wf02_mapping.dig, this step runs:
+prep: 
  td>: prep/queries/${tbl.src_table_name}.sql
  database: ${raw}_${sub}
```

This means for each table with PRP enabled, you can create a corresponding SQL file in `prep/queries/` to transform your raw data.

### 2.6.2 Creating PRP Query Files

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

### 2.6.3 JSON Field Transformation Examples

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

### 2.6.4 Advanced JSON Transformation Techniques

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

### 2.6.5 Updating Schema Map for PRP-Transformed Fields

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

### 2.6.6 Time-based Incremental Processing

Include time-based filtering in your PRP queries for incremental processing:

```sql
-- Standard time filter for incremental processing
WHERE time >= {{ moment(session_time).subtract(1, 'day').unix() }}

-- Or for specific date ranges
WHERE DATE(time_column) >= DATE('{{ session_date }}') - INTERVAL '1' DAY
```

### 2.6.7 Data Quality Validation in PRP

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

### 2.6.8 Testing PRP Queries

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

### 2.6.9 Common JSON Functions in Treasure Data

| Function | Purpose | Example |
|----------|---------|---------|
| `JSON_EXTRACT_SCALAR(json, path)` | Extract scalar value | `JSON_EXTRACT_SCALAR(data, '$.name')` |
| `JSON_EXTRACT_ARRAY(json, path)` | Extract array | `JSON_EXTRACT_ARRAY(data, '$.items')` |
| `JSON_EXTRACT(json, path)` | Extract JSON object | `JSON_EXTRACT(data, '$.address')` |
| `JSON_VALID(json)` | Validate JSON format | `JSON_VALID(json_string)` |
| `JSON_SIZE(json, path)` | Get array/object size | `JSON_SIZE(data, '$.items')` |

---

## Step 3: Data Preparation

### 3.1 Verify Your Raw Data

Before running the workflow, ensure your raw data tables exist and contain the expected fields:

```sql
-- Check if your tables exist
SELECT * FROM INFORMATION_SCHEMA.TABLES where schema_name = 'your_database_name';

```
---

## Step 4: Initial Workflow Execution

### 4.1 Test Configuration

Start with a validation-only run to test your configuration:

1. Set `run_all: true` in `src_params.yml`
2. Run only the validation workflow first:

```bash
# In Treasure Data CLI, run:
td workflow run retail-starter-pack wf03_validate
```

### 4.2 Full Pipeline Execution

Once validation passes, run the complete pipeline:

```bash
# Run the main orchestration workflow
td workflow run retail-starter-pack wf00_orchestration
```

### 4.3 Monitor Execution

Monitor workflow progress in the Treasure Data console:
- Check workflow status and logs
- Verify databases and tables are created
- Review email notifications for success/failure

---

## Step 5: Post-Setup Configuration

### 5.1 Segment Configuration

After successful initial run, configure customer segments:

1. Review segment templates in `segment/config/segment_templates/`
2. Modify segment criteria to match your business needs
3. Update `src_params.yml` segment configuration:

```yaml
## PARENT SEGMENT/SEGMENT CONFIG ##
segment:
  run_type: create    # Change to 'update' after first run
```

### 5.2 Analytics Dashboard Setup

If dashboards were created, access them through:
- Treasure Data console → Treasure Insights
- Share with users listed in `dash_users_list`

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

#### Issue: Workflow fails during unification
**Solution:**
- Check for data quality issues (null emails, invalid formats)
- Verify identity keys (email, phone, customer_id) have good coverage
- Review staging data for completeness

#### Issue: No data in golden layer
**Solution:**
- Verify unification completed successfully
- Check identity resolution results
- Ensure identity keys are properly mapped

### Validation Queries

Run these queries to validate your setup:

```sql
-- Check row counts match between raw and staged data
SELECT 
  'raw' as layer, COUNT(*) as row_count 
FROM your_raw_database.customer_table
UNION ALL
SELECT 
  'staged' as layer, COUNT(*) as row_count 
FROM your_staging_database.loyalty_profile;

-- Verify identity resolution worked
SELECT 
  COUNT(DISTINCT canonical_id) as unique_customers,
  SUM(CASE WHEN email IS NOT NULL THEN 1 ELSE 0 END) as customers_with_email
FROM your_golden_database.unified_customers;

-- Check segment creation
SELECT segment_name, COUNT(*) as customer_count
FROM your_analytics_database.active_segments
GROUP BY segment_name;
```

### Getting Help

If you encounter issues:
1. **Check Logs**: Review workflow execution logs in TD console
2. **Email Reports**: Check validation reports sent to configured emails  
3. **Data Quality**: Run the validation queries above
4. **Configuration**: Double-check field mappings in `schema_map.yml`
5. **Support**: Contact your Treasure Data support team with specific error messages

---

## Best Practices

### Configuration Management
- **Version Control**: Keep configuration files in version control
- **Environment-Specific**: Use different configs for dev/staging/prod  
- **Documentation**: Document any custom field mappings
- **Testing**: Always test configuration changes in development first

### Data Quality
- **Validation**: Run data quality checks before initial setup
- **Monitoring**: Set up ongoing data quality monitoring
- **Consistency**: Ensure consistent data formats across sources
- **Completeness**: Verify key identity fields have high completion rates

### Performance
- **Incremental Processing**: Consider incremental data loading after initial setup
- **Scheduling**: Set up appropriate workflow schedules
- **Resource Management**: Monitor workflow resource usage
- **Optimization**: Optimize queries for large datasets

### Security
- **PII Handling**: Ensure proper handling of personal data
- **Access Control**: Limit access to sensitive data
- **Compliance**: Follow data privacy regulations
- **Encryption**: Use appropriate data encryption

---

## Next Steps

After successful setup:

1. **Schedule Workflows**: Set up regular workflow schedules
2. **Create Segments**: Build customer segments for marketing campaigns  
3. **Set up Activations**: Connect segments to marketing platforms
4. **Monitor Performance**: Set up monitoring and alerting
5. **Iterate**: Continuously improve based on business needs

For advanced configuration and customization, refer to the [Workflow Deep Dive Documentation](workflows/README.md).