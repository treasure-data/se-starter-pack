# Treasure Data Retail Starter Pack - Workflow Deep Dive

## Overview

The Retail Starter Pack consists of 10 main workflow files (.dig) that orchestrate the complete customer data pipeline from raw ingestion to segmentation and activation. Each workflow has specific responsibilities and dependencies within the overall data processing architecture.

## Workflow Architecture

```
wf00_orchestration.dig (Master Controller)
    │
    └── wf01_run_workflow_with_logging.dig (Logging Wrapper)
            │
            ├── wf02_mapping.dig (Data Mapping & PRP)
            │
            ├── wf03_validate.dig (Data Validation)
            │
            ├── wf04_stage.dig (Data Staging)
            │
            ├── wf05_unify.dig (Identity Unification)
            │
            ├── wf06_golden.dig (Golden Layer Creation)
            │
            ├── wf07_analytics.dig (Analytics & Dashboards)
            │   │
            │   └── [Parallel Execution]
            │
            ├── wf08_create_refresh_master_segment.dig (Master Segments)
            │
            └── wf09_create_segment.dig (Individual Segments)
```

## Data Flow Architecture

```
[Raw Data] → [PRP Layer] → [Source] → [Staging] → [Unification] → [Golden] → [Analytics/Segments]
     ↓            ↓           ↓          ↓            ↓            ↓            ↓
raw_${sub}   prp_${sub}  src_${sub}  stg_${sub}  cdp_unif_${sub} gld_${sub}  ana_${sub}
```

---

## Individual Workflow Documentation

### wf00_orchestration.dig - Master Orchestrator

**Purpose**: Central control workflow that manages the entire data pipeline execution

#### Key Responsibilities:
- **Database Management**: Creates and manages 4 core databases
- **Global Configuration**: Sets project-wide parameters and configurations
- **Workflow Orchestration**: Controls execution order and dependencies
- **Error Handling**: Provides pipeline-level error management and notifications

#### Configuration Files:
- `config/src_params.yml` - Main configuration parameters
- `config/email_ids.yml` - Email notification settings

#### Database Structure Created:
```yaml
va_config_${sub}:    # Configuration and logging database
${stg}_${sub}:       # Staging database  
${gld}_${sub}:       # Golden layer database
${ana}_${sub}:       # Analytics database
```

#### Execution Flow:
1. **Setup Phase**: Database creation and parameter initialization
2. **Mapping Phase**: Raw data transformation (wf02)
3. **Validation Phase**: Data quality checks (wf03)
4. **Staging Phase**: Data preparation for unification (wf04)
5. **Unification Phase**: Identity resolution (wf05)
6. **Golden Phase**: Master data layer creation (wf06)
7. **Parallel Analytics**: Analytics and segment creation (wf07, wf08)
8. **Segmentation**: Individual segment creation (wf09) - Optional

#### Error Handling:
- Email notifications on success/failure
- Workflow-level error propagation
- Logging to `va_config_${sub}.log_tbl`

#### Parameters:
```yaml
sub: ${TD_PROJECT}              # Project identifier
run_all: true/false            # Force re-run completed workflows
email_success: true/false      # Send success notifications
email_failure: true/false      # Send failure notifications
```

---

### wf01_run_workflow_with_logging.dig - Logging Wrapper

**Purpose**: Provides execution logging and conditional run logic for all child workflows

#### Key Responsibilities:
- **Status Tracking**: Monitors workflow execution status
- **Conditional Execution**: Implements smart skip logic for completed workflows
- **Logging Infrastructure**: Maintains execution logs and audit trail
- **Error Recovery**: Provides restart capability from failure points

#### Core Logic:
```sql
-- Check if workflow should run
SELECT CASE 
  WHEN '${run_all}' = 'true' THEN 'run'
  WHEN status = 'success' THEN 'skip'
  ELSE 'run'
END as should_run
FROM log_tbl WHERE workflow = '${workflow_name}'
```

#### Logging Structure:
```yaml
Table: va_config_${sub}.log_tbl
Columns:
  - workflow: string       # Workflow identifier
  - status: string         # success/failure/running
  - start_time: timestamp  # Execution start
  - end_time: timestamp    # Execution end
  - error_message: string  # Error details if failed
```

#### Parameters:
- `workflow_name`: Name of the workflow being executed
- `run_all`: Override flag to force re-execution
- `database`: Target database for the workflow

---

### wf02_mapping.dig - Data Mapping and PRP Processing

**Purpose**: Transforms raw data using schema mapping configuration and PRP logic

#### Key Responsibilities:
- **Schema Mapping**: Applies field transformations based on `schema_map.yml`
- **PRP Processing**: Implements Profile-Ready Processing layer
- **Data Standardization**: Normalizes data formats and types
- **Parallel Processing**: Processes all tables simultaneously for performance

#### PRP Logic Implementation:
```yaml
# For tables with PRP enabled
+prp:
  for_each>:
    table: ${tables_with_prp}
  _do:
    td>: prep/queries/${table.src_table_name}.sql
    database: ${prp}_${sub}
```

#### Schema Mapping Process:
1. **Configuration Loading**: Reads field mappings from `schema_map.yml`
2. **Dynamic Query Generation**: Creates transformation SQL for each table
3. **Column Mapping**: Maps source columns to target schema
4. **Data Type Conversion**: Applies appropriate data type transformations
5. **Table Creation**: Creates mapped tables in target databases

#### Input/Output:
- **Input**: `${raw}_${sub}` database tables
- **Output**: `${src}_${sub}` and `${prp}_${sub}` database tables

#### Configuration Example:
```yaml
# schema_map.yml excerpt
loyalty_profile:
  prp_table_name: loyalty_profile
  columns:
    customer_id:
      prp: customer_id
      src: cust_id
      type: string
    email:
      prp: email_address
      src: email
      type: string
```

#### Parallel Processing:
- All table mappings execute simultaneously
- Independent error handling per table
- Optimized for large datasets

---

### wf03_validate.dig - Data Validation and Quality Assurance

**Purpose**: Comprehensive data validation and quality reporting system

#### Key Responsibilities:
- **Schema Validation**: Verifies table and column existence
- **Data Type Validation**: Checks data type consistency
- **Quality Reporting**: Generates detailed validation reports
- **Error Detection**: Identifies critical data issues

#### Validation Checks:
1. **Missing Tables**: Identifies tables absent from source
2. **Missing Columns**: Detects missing required columns
3. **Type Mismatches**: Validates data type consistency
4. **Data Quality**: Statistical analysis of data completeness

#### Validation Query Structure:
```sql
-- Example validation query
SELECT 
  table_name,
  column_name,
  expected_type,
  actual_type,
  CASE 
    WHEN actual_type != expected_type THEN 'TYPE_MISMATCH'
    WHEN column_name IS NULL THEN 'MISSING_COLUMN'
    ELSE 'VALID'
  END as validation_status
FROM schema_validation_${table}
```

#### Report Generation:
- **HTML Reports**: Generated via Python `validation.python.gen_html.main`
- **Email Notifications**: Automated delivery of validation results
- **Statistical Analysis**: Data completeness and quality metrics

#### Error Conditions:
- **Critical**: Missing tables or required columns - Workflow fails
- **Warning**: Data quality issues - Workflow continues with alerts
- **Info**: Statistical anomalies - Logged for review

#### Configuration:
```yaml
# Validation thresholds
validation_config:
  fail_on_missing_table: true
  fail_on_missing_column: true
  warn_on_type_mismatch: true
  quality_threshold: 0.95
```

---

### wf04_stage.dig - Data Staging and Preparation

**Purpose**: Prepares and stages data for identity unification

#### Key Responsibilities:
- **Data Cleansing**: Applies business rules and data cleansing
- **Email Validation**: Creates invalid email lookup tables
- **Data Standardization**: Normalizes data formats for unification
- **Staging Table Creation**: Prepares data for unification processing

#### Email Validation Process:
```sql
-- Invalid emails identification
CREATE TABLE ${stg}_${sub}.invalid_emails AS
SELECT DISTINCT email
FROM (
  SELECT email FROM ${src}_${sub}.loyalty_profile WHERE email IS NOT NULL
  UNION ALL
  SELECT email FROM ${src}_${sub}.email_activity WHERE email IS NOT NULL
  -- Additional email sources
) emails
WHERE email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
```

#### Staging Transformations:
- **Data Normalization**: Phone number formatting, email case standardization
- **Null Handling**: Consistent null value treatment
- **Date Formatting**: ISO8601 date standardization
- **Identifier Cleansing**: Customer ID, email, phone number validation

#### Parallel Processing:
```yaml
+stage_all_tables:
  for_each>:
    table: ${table_list}
  _parallel: true
  _do:
    td>: staging/queries/${table.src_table_name}.sql
```

#### Input/Output:
- **Input**: `${src}_${sub}` - Source processed data
- **Output**: `${stg}_${sub}` - Staged data ready for unification

#### Data Quality Enhancements:
- Email format validation and flagging
- Phone number normalization (remove formatting)
- Address standardization
- Customer ID deduplication

---

### wf05_unify.dig - Identity Unification

**Purpose**: Performs customer identity resolution using Treasure Data's unification engine

#### Key Responsibilities:
- **Identity Resolution**: Merges customer identities across data sources
- **Canonical ID Creation**: Generates unique customer identifiers
- **Identity Graph**: Creates relationships between different identifiers
- **Unification API Integration**: Leverages TD's unification service

#### Unification Configuration:
```yaml
# unification/unify.yml
unification_config:
  keys:
    - email
    - phone_number
    - customer_id
    - td_client_id
  rules:
    exact_match:
      - email
      - phone_number
    fuzzy_match:
      - name + address
  output_table: "unified_identities"
```

#### API Integration:
```yaml
# Unification API call
http>: https://api.treasuredata.com/v4/unification
method: POST
content:
  database: ${stg}_${sub}
  config: unification/unify.yml
  mode: full_refresh
```

#### Identity Resolution Process:
1. **Data Preparation**: Prepares identity keys from staged data
2. **Matching Rules**: Applies exact and fuzzy matching algorithms
3. **Graph Generation**: Creates identity relationship graph
4. **Canonical Assignment**: Assigns unique canonical IDs
5. **Lookup Creation**: Generates identity lookup tables

#### Output Tables:
- **Identity Lookup**: Maps source IDs to canonical IDs
- **Identity Graph**: Shows relationships between identifiers
- **Unification Stats**: Provides matching statistics and quality metrics

#### Matching Logic:
- **Exact Match**: Email, phone number, customer ID
- **Probabilistic Match**: Name + address, name + phone
- **Transitive Linking**: Links identities through common identifiers

---

### wf06_golden.dig - Golden Layer Creation

**Purpose**: Creates the master/golden data layer with enriched, unified customer data

#### Key Responsibilities:
- **Data Unification**: Applies identity resolution to create single customer view
- **Attribute Derivation**: Creates enriched customer attributes
- **Data Enrichment**: Adds calculated fields and aggregations
- **Master Data Creation**: Builds authoritative customer data layer

#### Golden Layer Architecture:
```yaml
Golden Tables:
  - unified_customers       # Master customer profiles
  - customer_attributes     # Derived attributes
  - customer_behaviors      # Behavioral data
  - transaction_history     # Unified transaction data
  - engagement_metrics      # Email, web, app engagement
```

#### Attribute Derivation:
```sql
-- Example: Customer lifetime value calculation
CREATE TABLE ${gld}_${sub}.customer_attributes AS
SELECT 
  canonical_id,
  SUM(amount) as lifetime_value,
  COUNT(DISTINCT order_no) as total_orders,
  AVG(amount) as avg_order_value,
  MAX(order_datetime) as last_purchase_date,
  MIN(order_datetime) as first_purchase_date
FROM unified_transactions
GROUP BY canonical_id
```

#### Parallel Processing:
```yaml
+derive_attributes:
  _parallel: true
  email_activity: 
    td>: golden/queries/attributes/email_activity.sql
  pageviews:
    td>: golden/queries/attributes/pageviews.sql  
  transactions:
    td>: golden/queries/attributes/transactions.sql
```

#### Data Enrichment Features:
- **Customer Scoring**: RFM analysis, propensity scores
- **Behavioral Segments**: Purchase patterns, engagement levels
- **Lifetime Metrics**: CLV, tenure, frequency
- **Preferences**: Product affinities, channel preferences

#### Copy Operations:
- Unified tables copied from unification database
- Table structures preserved with additional enrichments
- Metadata and audit fields added

---

### wf07_analytics.dig - Analytics and Dashboard Creation

**Purpose**: Creates business intelligence datasets and automated dashboards

#### Key Responsibilities:
- **Sales Analytics**: Revenue trends, product performance
- **Web Analytics**: Visitor behavior, conversion analysis
- **Dashboard Automation**: Creates and refreshes Treasure Data dashboards
- **Data Model Management**: Maintains analytics data models

#### Analytics Components:

##### Sales Analytics:
```sql
-- Sales trends analysis
CREATE TABLE sales_trends AS
SELECT 
  DATE_TRUNC('month', order_datetime) as month,
  SUM(amount) as total_revenue,
  COUNT(DISTINCT canonical_id) as unique_customers,
  COUNT(DISTINCT order_no) as total_orders,
  AVG(amount) as avg_order_value
FROM ${gld}_${sub}.unified_transactions
GROUP BY 1
ORDER BY 1
```

##### Web Analytics:
- **Conversion Funnels**: Page view to purchase conversion
- **Sankey Diagrams**: Customer journey visualization  
- **Session Analysis**: Engagement metrics and patterns
- **Attribution Analysis**: Channel effectiveness

##### Market Basket Analysis:
```sql
-- Product affinity analysis
SELECT 
  a.product_id as product_a,
  b.product_id as product_b,
  COUNT(*) as frequency,
  COUNT(*) / SUM(COUNT(*)) OVER() as support
FROM order_details a
JOIN order_details b ON a.order_no = b.order_no AND a.product_id < b.product_id
GROUP BY 1, 2
HAVING COUNT(*) >= 10
```

#### Dashboard Creation:
- **Automated API Calls**: Creates dashboards via Treasure Data API
- **Template-Based**: Uses predefined dashboard templates
- **Data Model Integration**: Connects dashboards to analytics data models
- **Scheduled Refresh**: Automatic data model updates

#### Parallel Execution:
```yaml
+analytics_parallel:
  _parallel: true
  sales_analytics:
    td>: analytics/queries/sales/
  web_analytics:  
    td>: analytics/queries/web_analytics/
  idu_dashboard:
    call>: idu_dashboard/idu_dashboard_launch.dig
```

---

### wf08_create_refresh_master_segment.dig - Master Segment Management

**Purpose**: Creates and manages master customer segments for targeting and activation

#### Key Responsibilities:
- **Parent Segment Creation**: Builds master audience segments
- **Template Management**: Processes segment definition templates
- **Audience Management**: Manages active audience definitions
- **Segment Refresh**: Updates segments with new data

#### Segment Template Structure:
```yaml
# Example segment template
segment_template:
  name: "High Value Customers"
  description: "Customers with high lifetime value"
  criteria:
    lifetime_value: ">= 1000"
    last_purchase_days: "<= 90"
    total_orders: ">= 5"
  refresh_schedule: "daily"
```

#### Template Processing:
```python
# Python segment creation
def create_parent_segments():
    templates = load_segment_templates()
    for template in templates:
        segment_sql = generate_segment_query(template)
        create_audience(template.name, segment_sql)
        log_segment_creation(template.name, 'success')
```

#### Audience Management:
- **Active Audience Tracking**: Monitors segment performance
- **Template Validation**: Ensures segment definitions are valid
- **Parallel Processing**: Creates multiple segments simultaneously
- **Error Handling**: Individual segment error isolation

#### Segment Types:
- **Behavioral Segments**: Based on purchase patterns
- **Demographic Segments**: Age, location, preferences
- **Engagement Segments**: Email, web, app engagement levels  
- **Value Segments**: RFM, CLV, spending patterns

#### API Integration:
- **Audience Studio API**: Creates segments in Treasure Data platform
- **Status Monitoring**: Tracks segment build progress
- **Error Reporting**: Logs and reports segment creation issues

---

### wf09_create_segment.dig - Individual Segment Creation

**Purpose**: Creates individual customer segments based on specific templates and criteria

#### Key Responsibilities:
- **Template-Based Segmentation**: Processes individual segment templates
- **Audience-Specific Creation**: Creates segments for specific audience IDs
- **Batch Processing**: Handles multiple segment creation requests
- **Logging and Monitoring**: Tracks individual segment creation status

#### Segment Creation Process:
1. **Template Loading**: Reads segment definition templates
2. **Query Generation**: Creates SQL queries based on template criteria
3. **Segment Execution**: Runs segmentation queries against golden layer
4. **Audience Creation**: Creates audiences in Treasure Data platform
5. **Status Logging**: Records creation status and metrics

#### Template Processing:
```yaml
+create_segments:
  for_each>:
    template: ${segment_templates}
  _parallel: true
  _do:
    py>: segment.python.create_segment.main
    template_config: ${template}
    audience_id: ${template.audience_id}
```

#### Segment Configuration:
```yaml
# Individual segment template
segments_1.yml:
  segments:
    - name: "New Customers"
      sql_file: "new_customers.sql" 
      audience_id: "12345"
      schedule: "daily"
    - name: "Lapsed Customers"
      sql_file: "lapsed_customers.sql"
      audience_id: "12346" 
      schedule: "weekly"
```

#### Error Handling:
- **Individual Failure Isolation**: Failed segments don't affect others
- **Retry Logic**: Automatic retry for transient failures
- **Status Reporting**: Detailed logging of success/failure per segment
- **Template Validation**: Pre-execution validation of segment definitions

#### Integration Points:
- **Golden Layer**: Sources data from unified customer data
- **Audience Studio**: Creates targetable audiences
- **Analytics**: Provides segment performance metrics
- **Activation**: Enables segment use in campaigns

---

## Configuration Management

### Core Configuration Files:

#### src_params.yml
```yaml
# Main configuration
sub: ${TD_PROJECT}
raw: raw
prp: prp  
src: src
stg: staging
gld: golden
ana: analytics

# Table configuration
tables:
  - src_table_name: loyalty_profile
    ref_table_name: loyalty_profile_tmp
  - src_table_name: email_activity
    ref_table_name: email_activity_tmp
```

#### schema_map.yml
```yaml
# Field mapping configuration
loyalty_profile:
  prp_table_name: loyalty_profile
  columns:
    customer_id:
      prp: customer_id
      src: cust_id
      type: string
```

#### email_ids.yml
```yaml
# Email notification configuration
email_success: ["success@company.com"]
email_failure: ["alerts@company.com"]
```

## Error Handling and Monitoring

### Logging Infrastructure:
- **Central Logging**: All workflows log to `va_config_${sub}.log_tbl`
- **Status Tracking**: Success/failure status per workflow
- **Error Details**: Detailed error messages and stack traces
- **Execution Metrics**: Start/end times, duration, record counts

### Email Notifications:
- **Success Notifications**: Configurable success email alerts
- **Failure Alerts**: Immediate notification on workflow failures  
- **Validation Reports**: HTML reports with data quality issues
- **Dashboard Updates**: Notification when dashboards are refreshed

### Error Recovery:
- **Conditional Execution**: Skip successful workflows unless forced
- **Partial Restart**: Restart from specific workflow in pipeline
- **Data Validation**: Comprehensive validation before processing
- **Rollback Capability**: Ability to revert to previous successful state

---

## Performance Optimization

### Parallel Processing:
- **Table-Level Parallelism**: Process multiple tables simultaneously
- **Workflow-Level Parallelism**: Analytics and segments run in parallel
- **Query Optimization**: Optimized SQL for large dataset processing

### Resource Management:
- **Database Partitioning**: Efficient data organization
- **Query Optimization**: Performance-tuned SQL queries
- **Memory Management**: Efficient memory usage for large datasets
- **API Rate Limiting**: Controlled API usage to avoid throttling

### Scalability Features:
- **Dynamic Configuration**: Environment-specific parameters
- **Modular Architecture**: Easy addition of new data sources
- **Template-Based**: Scalable segment and dashboard creation
- **API Integration**: Leverages Treasure Data platform capabilities