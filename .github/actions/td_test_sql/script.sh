#Test TD

function td_test_sql(){
    echo ===== Testing SQL
    if [[ $INPUT_FBRANCH == '' ]]; then
      if [[ $INPUT_ENV_LABEL == '' ]]; then
        td_db_name="$INPUT_TEST_DB" #testing_db
      else
        td_db_name="$INPUT_TEST_DB"_"$INPUT_ENV_LABEL" #testing_db_qa
      fi
    else
      if [[ $INPUT_ENV_LABEL == '' ]]; then
        td_db_name="$INPUT_TEST_DB"_"$INPUT_FBRANCH" #testing_db_f123
      else
        td_db_name="$INPUT_TEST_DB"_"$INPUT_ENV_LABEL"_"$INPUT_FBRANCH" #testing_db_qa_f123
      fi
    fi
    resp=$(curl -s -w "%{http_code}" --request POST "$INPUT_API_ENDPOINT/v3/job/issue/presto/$td_db_name" \
      --header "Authorization: TD1 $INPUT_TD_ACCESS_TOKEN" \
      --header "Content-Type: application/json" \
      --data-raw '{ "query":"'"$INPUT_SQL_STRING"'", "priority":"0", "result_url":"", "retry_limit":"0", "pool_name":"" }') 

    #Here's some boilerplate to deal with the status code
    echo -e "===== Response status code $resp"
    unaccepted_status_code_regex='^4[0-9]{2}|5[0-9]{2}'
    if [[ "$http_code" =~ $unaccepted_status_code_regex ]]; then
        exit 1
    else
      sleep 30
      id=$(echo $resp|sed 's/,/,\n/g'|grep -o '"job_id":"[^"]*' | grep -o '[^"]*$'|head -1)
      echo -e "===== id $id" 
      resp=$(curl -s -w "%{http_code}" --request GET "$INPUT_API_ENDPOINT/v3/job/status/$id" \
      --header "Authorization: TD1 $INPUT_TD_ACCESS_TOKEN") 
      echo -e "===== Response status code $resp" 
      if [[ "$http_code" =~ $unaccepted_status_code_regex ]]; then
       exit 1
      else
        echo -e "==== Success running SQL"
        echo $resp|sed 's/,/,\n/g'|grep -o '"status":"[^"]*' | grep -o '[^"]*$'|head -1
      fi
    fi
}

td_test_sql 