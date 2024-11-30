drop table if exists formfills_tmp;

create table formfills_tmp (
   email varchar,
   phone_number varchar,
   td_global_id varchar,
   td_client_id varchar, 
   form_type varchar,  
   time bigint
);