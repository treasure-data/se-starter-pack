drop table if exists pageviews_tmp;

create table pageviews_tmp (
    td_url varchar,
    td_path varchar,
    td_title varchar,
    td_description varchar,
    td_host varchar,
    td_language varchar,
    td_charset varchar,
    td_os varchar,
    td_os_version varchar,
    td_user_agent varchar,
    td_platform varchar,
    td_screen varchar,
    td_viewport varchar,
    td_color varchar,
    td_version varchar,
    td_global_id varchar,
    td_client_id varchar,
    td_ip varchar,
    td_referrer varchar,
    td_browser varchar,
    td_browser_version varchar,
    time bigint
);