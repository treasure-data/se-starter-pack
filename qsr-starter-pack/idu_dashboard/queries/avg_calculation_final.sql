select DISTINCT time as time_unixtime, substr(cast(from_unixtime(time) as VARCHAR),1,10) as datetime
  ,(SELECT avg_id FROM ${prefix}avg_min_max WHERE id_type = 'email') as avg_emails 
  ,(SELECT avg_id FROM ${prefix}avg_min_max WHERE id_type = 'cookie_1p') as avg_1p 
  ,(SELECT avg_id FROM ${prefix}avg_min_max WHERE id_type = 'cookie_3p') as avg_3p
  ,(SELECT avg_id FROM ${prefix}avg_min_max WHERE id_type = 'user_account_id') as avg_ssc 
from ${prefix}avg_min_max a