select
CAST(CAST(CURRENT_DATE as TIMESTAMP) as VARCHAR) as date,
APPROX_PERCENTILE(aov, .25) as aov_first_quartile,
APPROX_PERCENTILE(aov, .50) as aov_median,
APPROX_PERCENTILE(aov, .75) as aov_third_quartile,
APPROX_PERCENTILE(ltv, .25) as ltv_first_quartile,
APPROX_PERCENTILE(ltv, .50) as ltv_median,
APPROX_PERCENTILE(ltv, .75) as ltv_third_quartile,
APPROX_PERCENTILE(avg_days_between_transactions, .25) as avg_days_between_transactions_first_quartile,
APPROX_PERCENTILE(avg_days_between_transactions, .50) as avg_days_between_transactions_median,
APPROX_PERCENTILE(avg_days_between_transactions, .75) as avg_days_between_transactions_third_quartile
from
${src_database}.derived_attributes;