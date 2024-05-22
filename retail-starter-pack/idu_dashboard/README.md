# General Overview

The **ID Unification Dashboard** aims to assist customers in understanding the average number of IDs, emails, devices, etc., associated with a user's profile. It offers high-level metrics and detailed insights to demonstrate the overall deduplication rates and potential cost savings over time. Additionally, it provides a comparison of known vs. unknown customer counts and the IDs and ID types responsible for incorrect over-merging.

## Requirements

To effectively use the ID Unification Dashboard, the following knowledge is required:
- Understanding of Presto/Hive, DigDag, Python Custom Scripting, Experience with Treasure Insights

## Tech Implementation Summary

### Prerequisites

- **ID Unification Workflow**: This is the primary workflow that executes the unification process. This has to be ran before the IDU Dashboard can be built, as the Dashboard needs the output tables in the ***cdp_unification*** database

  - ***Project Name:*** the name of the IDU Workflow Project

  - ***Workflow Name:***  - the name of the `.dig` file that runs the unification process

- **ID Unification Workflow Stats**: These are statistics tables run as part of the ID unification workflow. They provide necessary information for evaluating the state before and after unification.

  - `canonical_id_source_key_stats`
  - `canonical_id_result_key_stats`
  - `canonical_id_result_key_stats`
  - `enriched_user_master or identity tables` (if applicable)

- **Definition of “Addressable ID” and Known ID***

An *Addressable ID* refers to ID types that can be utilized for direct marketing, targeting known users, such as `email, phone etc.` (ex.. This is set as a list in the `config/params.yml` file within the ID unification dashboard workflow. An example configuration is provided in the following section.

## Model Parameters in `config/params.yml`

Below is a detailed description of each required parameter for the workflow (WF) to run end-to-end:

```yaml
# Example configuration in config/params.yml

###Database created by unification workflow where the id_lookup and key_stats tables live
source_db: cdp_unification_prd

##Reporting database (output DB where idu_dashboard tables are written) --> sink_database should be SAME as reporting_db
reporting_db: reporting_prod
sink_database: reporting_prod

##Global Prams
canonical_id_col: 'td_canonical_id'                 #name of the canonical ID col output by unification workflow
prefix: 'idu_'
api_endpoint: api.treasuredata.com
workflow_api_url: api-workflow.treasuredata.com     ##- use 'api-workflow.eu01.treasuredata.com' for EU Region
model_config_table: 'datamodel_build_history'       ## table where model OID is saved to be used for udpating datamodel/dashboard via API
create_dashboard: 'yes'

##Input Tables with ID Stats before and after Unification Process
canonical_id_source_key_stats: canonical_id_source_key_stats   #leave as DEFAULT
canonical_id_result_key_stats: canonical_id_result_key_stats   #leave as DEFAULT
id_lookup_table: ${source_db}.${canonical_id_col}_lookup       #leave as DEFAULT --> name of id_lookup table from unification DB
user_master_id_table: ${source_db}.enriched_master             #ONLY needed if source table id stats are output in enriched_master table in unification

##ID unification Project & Workflow
unification_project: 'deterministic_unification_prd'          #name of the unification WF project
unification_workflow: 'deterministic_unification_prd'         #name of the sub-wf .dig that runs unification process in the above project
num_runs: 30                                                  #Gets runtimes on the last n-runs of unification WF
unification_output: 'old'         ###-- use 'old' = when source tables are present in source_key_stats tables from IDU, use 'new' = source tables are in enriched_user_master

##id_list
include_all_cols: 'yes' ### yes --> includes all columns in the id_lookup_table. Use 'no' to only show columns in the dash that are listed under the distinct_ids list below.

distinct_ids:
  - col_name: email
    id_type: 'email'
    known: 1
    addressable: 1
  - col_name: phone
    id_type: 'phone'
    known: 1
    addressable: 1
  - col_name: td_client_id
    id_type: 'cookie_1p'
    known: 0
    addressable: 1
  - col_name: td_global_id
    id_type: 'cookie_3p'
    known: 0
    addressable: 0


########### IDU QA Params #######
run_qa: 'yes'             #if == 'yes' --> Runs idu_qa.dig, which gets stats on over-merged IDs
merged_ids_limit: 15      #param for deciding the number of Distinct IDs merged to a single canonical_id to be considered as an 'over-merged' record
```

# Workflow Code Walkthrough

This section provides a detailed walkthrough of the DigDag project files used in the ID Unification Dashboard workflow.

### DigDag Project Files

#### `idu_dashboard_data_prep.dig`
- **Purpose**: Performs the data-wrangling processes to output most of the IDU stats tables for the final dashboard.
- **Key Steps**:
  - ***+source / +results:*** Copies the most recent source and result stats from the ID unification workflow, storing them in tables `canonical_id_source_key_stats_top` and `canonical_id_result_key_stats_top`.
  - ***+determine_id_types:*** Obtains addressable IDs and stores other ID types as custom, outputting `columns_temp` and `columns_type`.
  - ***+calc_metrics / +id_calcs:*** Calculates overall ID unification stats and by-ID stats, outputting `calculations_temp`, `identities_temp`.
  - ***+get_session_info:*** Retrieves unification attempt info from the workflow runs, outputting `session_information_temp` and `session_information`.
  - ***+calculations_temp / +calculations_final / +matching_rate / +ids_histogram / +avg_min_max / +avg_calculations / +merge_keys_updated / +create_key_stats_join:*** Calculates additional overall statistics for unification, outputting data in a format for the dashboard. Outputs include the temp tables: `calculations_2`, and the data model tables `calculations`, `identities`, `matching_rate`, `ids_histogram`, `avg_min_max`, `avg_calculations`, `merge_keys_updated`, `stats_joined`.
  - ***+create_global_session_filter:*** Creates a session filter for the dashboard, stored in `global_session_filter`.

#### `idu_qa.dig`
- **Purpose**: Performs Q&A process on IDs causing over-merging and analyzes the graph relationship between these IDs and the source tables they originated from.

## SQL Queries

This section lists and describes the SQL queries used in the workflow.

### General Queries

- `queries/source_top.sql`: Copies the most recent source stats from the ID unification workflow.
- `queries/result_top.sql`: Copies the most recent result stats from the ID unification workflow.
- `queries/columns_temp.sql`: Transforms the list of addressable IDs from `params.yml` and sets all others to "custom".
- `queries/columns_pivot.sql`: Pivots ID list into rows with `id_type` flag (e.g., 'addressable' or 'custom').
- `queries/id_columns.sql`: Lists ID columns for use in `calculation_temp.sql`.
- `queries/calculation_temp.sql`: Creates high-level metrics for the dashboard, such as pre- and post-unification profiles, and 'addressable' vs. 'custom' ID totals.
- `queries/identities_list.sql`: Lists ID columns for use in `identities_temp.sql`.
- `queries/identities_temp.sql`: Creates a breakdown of source counts by ID.
- `queries/store_session_info.sql`: Saves metadata of recent sessions of the ID unification workflow.
- `queries/calculation_merge.sql`: Joins most recent session info with high-level metrics from `calculation_temp.sql`.
- `queries/calculation_final.sql`: Adds a date string column for the dashboard.
- `queries/identities_final.sql`: Adds a date string column for the dashboard.
- `queries/matching_rate.sql`: Calculates deduplication rate over time.
- `queries/ids_histogram.sql`: Extracts histogram data for various ID types.
- `queries/avg_min_max.sql`: Calculates average, minimum, and maximum count per profile.
- `queries/merge_keys_individual.sql`: Calculates deduplication contribution from each ID.
- `queries/join_top_stats.sql`: Retrieves stats by table for bar graph output.

### Q&A Queries

- `queries/qa/extract_overmerged_canonical_ids.sql`: Retrieves a table of all over-merged canonical_ids.
- `queries/qa/build_extract_ids_final.sql`: Generates dynamic query syntax for over-merging analysis.
- `queries/qa/extract_common_ids.sql`: Aggregates IDs causing over-merging and their linked IDs.

Workflow Outputs / Data Model Summary

The following 13 tables are output by the dashboard workflow and are to be used in creating the data model. Note: they will be prefixed with the prefix defined in the config/params.yml file. The default prefix is idu_.

- ***idu_canonical_id_source_key_stats_top*** (most recent source stats)

- ***idu_canonical_id_result_key_stats_top*** (most recent result stats)

- ***idu_columns_type***

- ***idu_session_information***

- ***idu_calculations***

- ***idu_identities***

- ***idu_matching_rate***

- ***idu_ids_histogram***

- ***idu_avg_min_max***

- ***idu_avg_calculations***

- ***idu_merge_keys_updated***

- ***idu_stats_joined***

- ***idu_qa_build_id_extracts*** -  generate dynamic syntax for the Over-Merging Q&A Queries

- ***idu_qa_over_merged_id_sets*** -  a table which is a graph-id of all IDs causing over-merging and their relationships to other IDs in the source tables

- ***idu_qa_common_ids*** - get an aggregate table of all the IDs causing over-merging and the arrays of other IDs they are linked to - this goes into the final dashboard Over-Merging tables

## Data Model Joins

This section outlines how various data tables are joined together in the ID Unification Dashboard workflow.

### Join Descriptions

1. **Join between `canonical_id_result_key_stats_top` and `canonical_id_source_key_stats_top`**
   - **On Column**: `from_table`
   - **Purpose**: This join is used to correlate results and source statistics based on the `from_table` column.

2. **Join between `columns_type.col_name` and `identities.column_name`**
   - **Purpose**: This join matches column names in the `columns_type` table with those in the `identities` table, facilitating the categorization of IDs.

3. **Join between `canonical_id_source_key_stats_top.total_distinct` and `calculations.profiles_before_unification`**
   - **Purpose**: This join is essential for comparing the total distinct values from the source stats with the profiles calculated as 'before unification', providing insights into the deduplication process.

<img width="888" alt="Screen Shot 2023-12-19 at 7 04 39 PM" src="https://github.com/treasure-data-ps/ps_ml_analytics_team_solutions_prod/assets/40249921/9ba478a8-3aa9-4112-adad-ab488fc0b316">

## Dashboard

The dashboard is designed to display the most recent and relevant data, based on the data model specified in the `config.json` file. Selecting the correct data model should yield all the expected visualizations. Below are some of the key features of the dashboard.

### Key Features

1. **Overall Deduplication Stats**
   - **Purpose**: This Section of the Dashboard provides high-level statistics about the latest run of the unification workflow. This is a crucial tool for analyzing and understanding the impact of the ID unification process. It helps in visualizing the efficiency of the workflow and provides actionable insights into data management and optimization strategies by summarizing some of the useful metrics below.
     - Summary of the ***distinct IDs present in the source tables*** before the unification process  and how many of them were `known/addressable or custom`
     - It shows the number of profiles that were unified and the ***overall deduplication rate***, , giving insights into the effectiveness of the unification process.

<img width="1345" alt="Screen Shot 2023-12-19 at 7 20 43 PM" src="https://github.com/treasure-data-ps/ps_ml_analytics_team_solutions_prod/assets/40249921/689c48a8-95ea-4a8f-9463-b9683df6f15d">


2. **Pre-Unification Summary**

   - **Purpose**: Two bar graphs showing the counts of different ID types that were unified, and how many were unified across different sources. 

The first bar graph Count of Source IDs is divided into two sections, `addressable` and `custom`. The ID types that come under addressable can be configured by the addressable_ids parameter in config/params.yml. Any other ID type picked up by the unification process will be under `custom`. 

The second stacked bar graph breaks the unified IDs down based on which data source the unified profiles came from. * on the left refers to the aggregated total across all data sources.

<img width="1345" alt="Screen Shot 2023-12-19 at 7 21 10 PM" src="https://github.com/treasure-data-ps/ps_ml_analytics_team_solutions_prod/assets/40249921/2dd4f0a1-8b6c-4254-b9d4-54144d1e21dd">

3.  **Post-Unification Summary**

  - **Purpose**: The widgets below show more details on the deduplication process. The snippet below shows line graphs of deduplication over time, identities per person based on different IDs, and the relative contribution to unification by ID type and source. This also shows how many `Known/Unknown` profiles there are and how many of them have `email, phone or any other important identifier`. Other widgets not shown break down the `AVG` number of IDs per unified profile for several key IDs.

<img width="1357" alt="Screen Shot 2023-12-19 at 7 21 32 PM" src="https://github.com/treasure-data-ps/ps_ml_analytics_team_solutions_prod/assets/40249921/c493d0c0-c811-4508-8e14-b5c1f9f5a0e4">

4. **Over-Merged ID Stats**

  - **Purpose**: The section shows how many profiles are considered over-merged and allows you to dig deeper into showing for each over-merged canonical_id, which were the source IDs and Source tables that caused the over-merging, so that these IDs can be reviewed with the customer and a decision can be made how the over-merging should be solved (Ex. Excluded profiles/IDs from the unification logic, so these profiles can be kept as sperate OR sovle via some type of data ***cleaning / composite ID solution***, which might be able to fix the over-merging problem).
    
  - Widget below shows the populations statistics for each ID used in unification and helps determine the distinct ID count above which a profile is considered over-merged /abnormal to the population.

<img width="1504" alt="Screen Shot 2024-01-12 at 12 21 36 PM" src="https://github.com/treasure-data-ps/ps_ml_analytics_team_solutions_prod/assets/40249921/a90c3a95-ff9f-461d-96c3-39c4bf90b796">

- Based on the 5-number Summary (Min, Q1, Median, Q3, Max) and the Standard Deviation of the distribution of DISTINCT ID counts for each ID type, we calculate the over_merge_limit metric based on the assumption that in a normal distribution --> 99% of data lies within 2.5*stdev from the mean:
  
```sql
SELECT CEILING(avg_id + 2.5*stddev_id) as over_merge_limit_stdev
```
- After that we extract the sets of IDs for each of the over-merged profiles and use the widgets below to find the lineage of how each ID is related to other set of IDs and what data sources / ID types might be the major causes of over-merging. This allows us to review this information with the customer and come to a decision whether these profiles should be excluded from the final unification logic OR some type of data cleaning / composite ID solution, might be able to fix the over-merging problem.

<img width="1352" alt="Screen Shot 2023-12-19 at 7 21 54 PM" src="https://github.com/treasure-data-ps/ps_ml_analytics_team_solutions_prod/assets/40249921/972cd3b8-f96b-4628-a533-a013be2b2fdc">

- `Copyright © 2022 Treasure Data, Inc. (or its affiliates). All rights reserved`


