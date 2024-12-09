
drop table if exists consents_tmp;

create table consents_tmp (
   id varchar,
   id_type varchar,
   consent_type varchar,
   consent_flag varchar,
   time bigint
);
