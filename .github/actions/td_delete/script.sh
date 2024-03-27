#Delete a project from TD
#$1: The base name of the project previously pushed into TD
#$2: The branch/suffix name of the project previously pushed into TD
#$3: The TD api access token to use in the web request
#$4: The TD endpoint url fragment to use in the web request (ie eu01, ap02). If "US", uses US default endpoint
#$5: The environment suffix of the deletion-deployment (ie dev, qa). If NULL, no suffix will be looked for
function delete_project_td(){
    #env label check
    if [[ $INPUT_ENV_LABEL == '' ]] ;then
        project_name="$1"_"$INPUT_FBRANCH" #ie staging_br123
    else
        project_name="$1"_"$INPUT_ENV_LABEL"_"$INPUT_FBRANCH" #ie staging_qa_br123
    fi

    echo ===finding id of project with name $project_name
    resp=$(curl --request GET "$INPUT_WF_ENDPOINT/api/console/projects?name=$project_name" \
        --header "Authorization: TD1 $INPUT_API_TOKEN") 

    #response is a json with the project id in it. Here's some akward pure shell to extract it
    #Note: this code assumes the json object will always have its fields in the same order
    pjid=${resp#*"id"} #cut out everything before "id" (project id follows)
    pjid=${pjid%%"name"*} #cut out everything after "name" (next json item)
    len_m1=$((${#pjid} - 6)) #find last index and cut away characters from back
    pjid=${pjid: 3:$len_m1} #cut out lingering junk from ends

    echo ===== Deleting project $pjid with url $INPUT_WF_ENDPOINT
    status_code=$(curl -s -o /dev/null -w "%{http_code}" \
      --request DELETE "$INPUT_WF_ENDPOINT/api/projects/$pjid" \
      --header "Authorization: TD1 $INPUT_API_TOKEN" \
      --header "Content-Type: application/json")
    
    #Here's some boilerplate to deal with the status code
    echo -e "===== Response status code $status_code"
    unaccepted_status_code_regex='^4[0-9]{2}|5[0-9]{2}'
    if [[ "$status_code" =~ $unaccepted_status_code_regex ]]; then
        exit 1
    fi
}

#Delete a database from TD
#$1: The base name of the database previously created in TD
#$2: The branch/suffix name of the database previously created TD
#$3: The TD api access token to use in the web request
#$4: The TD endpoint url fragment to use in the web request (ie eu01, ap02). If "US", uses US default endpoint
#$5: The environment suffix of the deletion-deployment (ie dev, qa). If NULL, no suffix will be looked for
function delete_database_td(){
    #env label check
    if [[ $INPUT_ENV_LABEL == '' ]] ;then
        database_name="$1"_"$INPUT_FBRANCH" #ie stage_br123
    else
        database_name="$1"_"$INPUT_ENV_LABEL"_"$INPUT_FBRANCH" #ie stage_qa_br123
    fi

    echo ===== Deleting database $database_name
    status_code=$(curl -s -w "%{http_code}" \
        --request POST "$INPUT_API_ENDPOINT/v3/database/delete/$database_name" \
        --header "Authorization: TD1 $INPUT_API_TOKEN" \
        --header "Content-Type: application/json")

    #Here's some boilerplate to deal with the status code
    echo -e "===== Response status code $status_code"
    unaccepted_status_code_regex='^4[0-9]{2}|5[0-9]{2}'
    if [[ "$status_code" =~ $unaccepted_status_code_regex ]]; then
        exit 1
    fi
}

#turn various pipe-separated variables into space-separated strings, which will be interpreted as arrays
base_projs=$(echo $INPUT_PROJ_DIRS | sed "s/|/ /g")
db_base_names=$(echo $INPUT_DB_NAMES | sed "s/|/ /g")


for base_proj in $base_projs ;do
    delete_project_td $base_proj 
done
for base_db in $db_base_names ;do
    delete_database_td $base_db 
done