with base as (select
    DATE_FORMAT(current_date,  '%Y-%m-%d 00:00:00.0') as today_datetime
  , format_datetime(from_unixtime(time), 'Y-MM-dd') as date
  , time
  , td_client_id
  , td_url
  , td_referrer as referrer
  , td_referrer as referrer_host
  , url_extract_parameter(td_url, 'utm_source')   as utm_source
  , url_extract_parameter(td_url, 'utm_medium')   as utm_medium
  , url_extract_parameter(td_url, 'utm_campaign') as utm_campaign
  , url_extract_parameter(td_url, 'utm_content')  as utm_content
  , case when td_referrer like '%google%'       then 'Google'
        when td_referrer like '%instagram%'    then 'Instagram'
        when td_referrer like '%snapshat%'     then 'Snapchat'
        when td_referrer like '%youtube%'      then 'Youtube'
        when td_referrer like '%twitter%'      then 'Twitter'
        when td_referrer like '%facebook%'     then 'Facebook'
        else null
	end as search_engine
  , TD_IP_TO_COUNTRY_NAME(td_ip)                         as country_by_ip
  , TD_IP_TO_SUBDIVISION_NAMES(td_ip)                    as subdivision_by_ip_array
  , array_join(TD_IP_TO_SUBDIVISION_NAMES(td_ip), ', ')  as subdivision_by_ip_list
  , TD_IP_TO_MOST_SPECIFIC_SUBDIVISION_NAME(td_ip)       as subdivision_by_ip_mostspecific
  , TD_IP_TO_LEAST_SPECIFIC_SUBDIVISION_NAME(td_ip)      as subdivision_by_ip_leastspecific
  , TD_IP_TO_CITY_NAME(td_ip)                            as city_by_ip
  , TD_IP_TO_LATITUDE(td_ip)                             as latitude_by_ip
  , TD_IP_TO_LONGITUDE(td_ip)                            as longitude_by_ip
  , TD_IP_TO_POSTAL_CODE(td_ip)                          as postalcode_by_ip
  , TD_IP_TO_CONNECTION_TYPE(td_ip)                      as connectiontype_by_ip
  , TD_IP_TO_DOMAIN(td_ip)                               as domain_by_ip
  , td_user_agent
  , case when element_at(td_parse_agent(td_user_agent), 'category') = 'pc'                                                                    then 'PC'
        when (element_at(td_parse_agent(td_user_agent), 'category') = 'smartphone') or
              (element_at(td_parse_agent(td_user_agent), 'category') = 'UNKNOWN' and td_parse_user_agent(td_user_agent, 'os_family') = 'iOS') then 'Mobile'
        when element_at(td_parse_agent(td_user_agent), 'category') = 'crawler' or
              element_at(td_parse_agent(td_user_agent), 'name') = 'UNKNOWN' or
              (element_at(td_parse_agent(td_user_agent), 'os') = 'Linux' and element_at(td_parse_agent(td_user_agent), 'name') = 'Safari')    then 'BOT/Crawler'
        when element_at(td_parse_agent(td_user_agent), 'category') = 'appliance'                                                              then 'Game Console'
        when element_at(td_parse_agent(td_user_agent), 'category') = 'misc'                                                                   then 'ETC'
        when element_at(td_parse_agent(td_user_agent), 'category') = 'UNKNOWN'                                                                then 'UNKNOWN'
        else element_at(td_parse_agent(td_user_agent), 'category') -- 나중에 다시 체크
    end as device_type
  , case when element_at(td_parse_agent(td_user_agent), 'category') = 'pc' then 'PC'
        when td_parse_user_agent(td_user_agent, 'device') = 'Other'        then 'UNKNOWN'
        else td_parse_user_agent(td_user_agent, 'device')
    end as device_name
  , if(td_parse_user_agent(td_user_agent, 'os_family') = 'iOS', 'iOS', element_at(td_parse_agent(td_user_agent), 'os'))       as os_name
  , element_at(td_parse_agent(td_user_agent), 'os_version')                                                                   as os_version
  , element_at(td_parse_agent(td_user_agent), 'vendor')                                                                       as browser_vendor
  , if(td_parse_user_agent(td_user_agent, 'ua_family') = 'Other', 'UNKNOWN', td_parse_user_agent(td_user_agent, 'ua_family')) as browser_name
  , element_at(td_parse_agent(td_user_agent), 'version')                                                                      as browser_version
  , td_language
--   , TD_SESSIONIZE_WINDOW(time, cast ('1800' as int)) OVER (PARTITION BY retail_unification_id ORDER BY time) AS session_id
  , TD_SESSIONIZE_WINDOW(time, cast ('${conversion.sessionize_time_range}' as int)) OVER (PARTITION BY retail_unification_id ORDER BY time) AS session_id
  , retail_unification_id
--   , cast(regexp_like(td_url, 'checkout') as varchar) conversion_flag
  , cast(regexp_like(td_url, '${conversion.pattern}') as varchar) conversion_flag
  from ${gld}_${sub}.enriched_pageviews a
  where TD_INTERVAL(a.time, '-365d')
)
select today_datetime as run_date, date, session_id, td_url, utm_source, utm_medium, utm_campaign, utm_content, search_engine, country_by_ip, subdivision_by_ip_list, city_by_ip, connectiontype_by_ip, domain_by_ip, device_type, os_name, browser_name, retail_unification_id, conversion_flag, count(1) count
from base
group by today_datetime, date, session_id, td_url, utm_source, utm_medium, utm_campaign, utm_content, search_engine, country_by_ip, subdivision_by_ip_list, city_by_ip, connectiontype_by_ip, domain_by_ip, device_type, os_name, browser_name, retail_unification_id, conversion_flag