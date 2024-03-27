#Test TD

function td_test_wf(){
  #Determine the project name
  if [[ $INPUT_FBRANCH == '' ]]; then
    if [[ $INPUT_ENV_LABEL == '' ]]; then
      td_project_name="$INPUT_TEST_WORKFLOW_PROJECT_NAME" #project
    else
      td_project_name="$INPUT_TEST_WORKFLOW_PROJECT_NAME"_"$INPUT_ENV_LABEL" #project_qa
    fi
  else
    if [[ $INPUT_ENV_LABEL == '' ]]; then
      td_project_name="$INPUT_TEST_WORKFLOW_PROJECT_NAME"_"$INPUT_FBRANCH" #project_f123
    else
      td_project_name="$INPUT_TEST_WORKFLOW_PROJECT_NAME"_"$INPUT_ENV_LABEL"_"$INPUT_FBRANCH" #project_qa_f123
    fi
  fi

  unaccepted_status_code_regex='^4[0-9]{2}|5[0-9]{2}'
  resp=$(curl -s -w "%{http_code}" --request GET "$INPUT_WF_ENDPOINT/api/projects?name=$td_project_name" \
                --header "Authorization: TD1 $INPUT_TD_ACCESS_TOKEN" \
                --header "Content-Type: application/json" ) 

  if [[ "$http_code" =~ $unaccepted_status_code_regex ]]; then
      exit 1
  else
    id=$(echo $resp|sed 's/,/,\n/g'|grep -o '"id":"[^"]*' | grep -o '[^"]*$'|head -1)
    if [[ $id == '' ]] ; then
        exit 1
    else
      resp=$(curl -s -w "%{http_code}" --request GET "$INPUT_WF_ENDPOINT/api/projects/$id/workflows/$INPUT_TEST_WORKFLOW_NAME" \
                --header "Authorization: TD1 $INPUT_TD_ACCESS_TOKEN" \
                --header "Content-Type: application/json" ) 

      if [[ "$http_code" =~ $unaccepted_status_code_regex ]]; then
        exit 1
      else
        id=$(echo $resp|sed 's/,/,\n/g'|grep -o '"id":"[^"]*' | grep -o '[^"]*$'|head -1)

        echo ===== Testing 
        #JSON_STRING='{ "sessionTime": "2023-08-20T16:20:25-04:00", "workflowId": "'"$INPUT_TEST_WORKFLOW_ID"'", "params": {} }'
        JSON_STRING='{ "sessionTime": "'"$(date +"%Y-%m-%dT%H:%M:%S%:z")"'", "workflowId": "'"$id"'", "params": {} }'
        #25506354
        echo -e $JSON_STRING
        resp=$(curl -s -w "%{http_code}" --request PUT "$INPUT_WF_ENDPOINT/api/attempts" \
          --header "Authorization: TD1 $INPUT_TD_ACCESS_TOKEN" \
          --header "Content-Type: application/json" \
          --data-raw '{ "sessionTime": "'"$(date +"%Y-%m-%dT%H:%M:%S%:z")"'", "workflowId": "'"$id"'", "params": {} }') 

        #Here's some boilerplate to deal with the status code
        echo -e "===== Response status code $resp" 
        
        if [[ "$http_code" =~ $unaccepted_status_code_regex ]]; then
          exit 1
        else
          sleep 30
          id=$(echo $resp|sed 's/,/,\n/g'|grep -o '"id":"[^"]*' | grep -o '[^"]*$'|head -1)
          echo -e "===== id $id" 
          resp=$(curl -s -w "%{http_code}" --request GET "$INPUT_WF_ENDPOINT/api/attempts/$id" \
          --header "Authorization: TD1 $INPUT_TD_ACCESS_TOKEN" \
          --header "Content-Type: application/json") 
          echo -e "===== Response status code $resp" 
          if [[ "$http_code" =~ $unaccepted_status_code_regex ]]; then
          exit 1
          else
            echo -e "==== Success running workflow"
            echo $resp|sed 's/,/,\n/g'|grep -o '"status":"[^"]*' | grep -o '[^"]*$'|head -1
          fi
        fi
      fi
    fi
  fi
  
    
    
}

td_test_wf
     