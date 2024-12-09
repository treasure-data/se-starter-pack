select
    time
  , td_time_string(time, 's!', 'CEST') as datetime_cest
  , td_time_string(time, 'd!', 'CEST') as date_cest
  , td_client_id
  -- , if(v.first_visit_date < td_time_string(time, 'd!', 'KST'), '재방문', '신규방문') as revisit_type_by_date
  , td_title
  , td_description
  , td_host
  , td_path
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
	end as search_engine    -- 검색엔진 구분. 추후에 UNKNOW 추가할 것
  , case when REGEXP_LIKE(td_referrer, '^https?://www\.google\..+/search\?.*') OR REGEXP_LIKE(td_referrer, '^https?://.*bing\.com/search\?.*') OR REGEXP_LIKE(td_referrer, '^https?://(m\.)?search\.daum\.net')
              then IF(LENGTH(TRIM(REPLACE(URL_EXTRACT_PARAMETER(td_referrer, 'q'), '+', ' '))) = 0, NULL, TRIM(REPLACE(URL_EXTRACT_PARAMETER(td_referrer, 'q'), '+', ' ')))       -- Google, Bing, Daum 의 경우
         when REGEXP_LIKE(td_referrer, '^https?://.*search\.yahoo\..*')
              then IF(LENGTH(TRIM(REPLACE(URL_EXTRACT_PARAMETER(td_referrer, 'p'), '+', ' '))) = 0, NULL, TRIM(REPLACE(URL_EXTRACT_PARAMETER(td_referrer, 'p'), '+', ' ')))        -- Yahoo 의 경우
         when REGEXP_LIKE(td_referrer, '^https?://(m\.)?search\.naver\.com') OR REGEXP_LIKE(td_referrer, '^https?://(m\.)?search\.zum\.com')
              then IF(LENGTH(TRIM(REPLACE(URL_EXTRACT_PARAMETER(td_referrer, 'query'), '+', ' '))) = 0, NULL, TRIM(REPLACE(URL_EXTRACT_PARAMETER(td_referrer, 'query'), '+', ' ')))   -- Naver, Zum 의 경우
  	     when REGEXP_LIKE(td_referrer, '^https?://(m\.)?prod\.danawa\.com')
  	          then IF(LENGTH(TRIM(REPLACE(URL_EXTRACT_PARAMETER(td_referrer, 'keyword'), '+', ' '))) = 0, NULL, TRIM(REPLACE(URL_EXTRACT_PARAMETER(td_referrer, 'keyword'), '+', ' ')))      -- Danawa 의 경우
         when REGEXP_LIKE(td_referrer, '^https?://(m\.)?searchassist\.verizon\.com')
  	          then IF(LENGTH(TRIM(REPLACE(URL_EXTRACT_PARAMETER(td_referrer, 'SearchQuery'), '+', ' '))) = 0, NULL, TRIM(REPLACE(URL_EXTRACT_PARAMETER(td_referrer, 'SearchQuery'), '+', ' ')))      -- Verizon 의 경우
         when REGEXP_LIKE(td_referrer, '^https?://(m|www)\.baidu\.com\/(s\?|link\?)')
  	          then IF(LENGTH(TRIM(REPLACE(URL_EXTRACT_PARAMETER(td_referrer, 'wd'), '+', ' '))) = 0, NULL, TRIM(REPLACE(URL_EXTRACT_PARAMETER(td_referrer, 'wd'), '+', ' ')))      -- Baidu 의 경우
  	     when REGEXP_LIKE(td_referrer, '^https?://(m|www)\.so\.com\/(s\?|link\?)')
              then IF(LENGTH(TRIM(REPLACE(URL_EXTRACT_PARAMETER(td_referrer, 'oq'), '+', ' '))) = 0, NULL, TRIM(REPLACE(URL_EXTRACT_PARAMETER(td_referrer, 'q'), '+', ' ')))      -- SO靠谱 의 경우
         when REGEXP_LIKE(td_referrer, 'https?://wap\.sogou\.com\/\w.+?keyword')
              then IF(LENGTH(TRIM(REPLACE(URL_EXTRACT_PARAMETER(td_referrer, 'keyword'), '+', ' '))) = 0, NULL, TRIM(REPLACE(URL_EXTRACT_PARAMETER(td_referrer, 'keyword'), '+', ' ')))      -- sogou 의 경우
  	     else null
    end as search_keyword
  , case when REGEXP_LIKE(td_referrer, '^https?://www\.google\..+/search\?.*')
  	          then IF(LENGTH(TRIM(REPLACE(URL_EXTRACT_PARAMETER(td_referrer, 'oq'), '+', ' '))) = 0, NULL, TRIM(REPLACE(URL_EXTRACT_PARAMETER(td_referrer, 'oq'), '+', ' ')))      -- Google 의 경우
  	     when REGEXP_LIKE(td_referrer, '^https?://.*bing\.com/search\?.*')
  	          then IF(LENGTH(TRIM(REPLACE(URL_EXTRACT_PARAMETER(td_referrer, 'pq'), '+', ' '))) = 0, NULL, TRIM(REPLACE(URL_EXTRACT_PARAMETER(td_referrer, 'pq'), '+', ' ')))      -- Bing 의 경우
	     when REGEXP_LIKE(td_referrer, '^https?://(m\.)?search\.daum\.net')
  	          then IF(LENGTH(TRIM(REPLACE(URL_EXTRACT_PARAMETER(td_referrer, 'sq'), '+', ' '))) = 0, NULL, TRIM(REPLACE(URL_EXTRACT_PARAMETER(td_referrer, 'sq'), '+', ' ')))      -- Daum 의 경우
         when REGEXP_LIKE(td_referrer, '^https?://(m\.)?search\.naver\.com')
              then IF(LENGTH(TRIM(REPLACE(URL_EXTRACT_PARAMETER(td_referrer, 'acq'), '+', ' '))) = 0, NULL, TRIM(REPLACE(URL_EXTRACT_PARAMETER(td_referrer, 'acq'), '+', ' ')))     -- Naver의 경우
         when REGEXP_LIKE(td_referrer, '^https?://(m\.)?search\.zum\.com')
              then IF(LENGTH(TRIM(REPLACE(URL_EXTRACT_PARAMETER(td_referrer, 'sug_q'), '+', ' '))) = 0, NULL, TRIM(REPLACE(URL_EXTRACT_PARAMETER(td_referrer, 'sug_q'), '+', ' ')))   -- Zum 의 경우
         when REGEXP_LIKE(td_referrer, '^https://(m|www)\.baidu\.com\/(s\?|link\?)')
  	          then IF(LENGTH(TRIM(REPLACE(URL_EXTRACT_PARAMETER(td_referrer, 'prefixsug'), '+', ' '))) = 0, NULL, TRIM(REPLACE(URL_EXTRACT_PARAMETER(td_referrer, 'prefixsug'), '+', ' ')))      -- Baidu 의 경우
         else  null
    end as search_keyword_input
  , case when REGEXP_LIKE(td_referrer, '^https?://(m\.)?search\.daum\.net')
  	          then IF(LENGTH(TRIM(REPLACE(URL_EXTRACT_PARAMETER(td_referrer, 'nzq'), '+', ' '))) = 0, NULL, TRIM(REPLACE(URL_EXTRACT_PARAMETER(td_referrer, 'nzq'), '+', ' ')))      -- Daum 의 경우
         when REGEXP_LIKE(td_referrer, '^https?://(m\.)?search\.naver\.com')
              then IF(LENGTH(TRIM(REPLACE(URL_EXTRACT_PARAMETER(td_referrer, 'oquery'), '+', ' '))) = 0, NULL, TRIM(REPLACE(URL_EXTRACT_PARAMETER(td_referrer, 'oquery'), '+', ' ')))     -- Naver의 경우
         else null end as search_keyword_previous
  , td_ip
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
        when element_at(td_parse_agent(td_user_agent), 'category') = 'appliance'                                                             then 'Game Console'
        when element_at(td_parse_agent(td_user_agent), 'category') = 'misc'                                                                  then 'ETC'
        when element_at(td_parse_agent(td_user_agent), 'category') = 'UNKNOWN'                                                               then 'UNKNOWN'
        else element_at(td_parse_agent(td_user_agent), 'category') -- 나중에 다시 체크
    end as device_type
  , case when element_at(td_parse_agent(td_user_agent), 'category') = 'pc' then 'PC'
        when td_parse_user_agent(td_user_agent, 'device') = 'Other'       then 'UNKNOWN'
        else td_parse_user_agent(td_user_agent, 'device')
    end as device_name
  , if(td_parse_user_agent(td_user_agent, 'os_family') = 'iOS', 'iOS', element_at(td_parse_agent(td_user_agent), 'os'))       as os_name
  , element_at(td_parse_agent(td_user_agent), 'os_version')                                                                   as os_version
  , element_at(td_parse_agent(td_user_agent), 'vendor')                                                                       as browser_vendor
  , if(td_parse_user_agent(td_user_agent, 'ua_family') = 'Other', 'UNKNOWN', td_parse_user_agent(td_user_agent, 'ua_family')) as browser_name
  , element_at(td_parse_agent(td_user_agent), 'version')                                                                      as browser_version
  , td_language
from
    ${src_database}.pageviews
where (td_client_id is not null or td_client_id != '')
;