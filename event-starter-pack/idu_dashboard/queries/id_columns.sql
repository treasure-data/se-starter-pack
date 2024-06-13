
SELECT ARRAY_JOIN(all_id_cols,', ') as all_id_cols,
       ARRAY_JOIN(addressable_cols,', ') as addressable_cols,
       ARRAY_JOIN(non_addressable_cols,', ') as non_addressable_cols,
       ARRAY_JOIN(known_ids_cols,', ') as known_ids_cols,
       ARRAY_JOIN(unknown_ids_cols,', ') as unknown_ids_cols,
       ARRAY_JOIN(composite_ids_cols,', ') as composite_ids_cols,
      sum_addressable,
      sum_non_addressable,
      sum_known,
      sum_unknown,
      sum_composite
FROM ${reporting_db}.${prefix}columns_temp 