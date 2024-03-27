#function to get project_id (output $pjid) given a project name ($1)
function get_project_id_from_name() {
  #Determine the project name from env label and fbranch label
  if [[ $INPUT_FBRANCH == '' ]]; then
    if [[ $INPUT_ENV_LABEL == '' ]]; then
      td_project_name="$1" #project
    else
      td_project_name="$1"_"$INPUT_ENV_LABEL" #project_qa
    fi
  else
    if [[ $INPUT_ENV_LABEL == '' ]]; then
    td_project_name="$1"_"$INPUT_FBRANCH" #project_f123
    else
      td_project_name="$1"_"$INPUT_ENV_LABEL"_"$INPUT_FBRANCH" #project_qa_f123
    fi
  fi

  echo ===finding id of project with name $td_project_name
  resp=$(curl --request GET "$INPUT_WF_ENDPOINT/api/console/projects?name=$td_project_name" \
    --header "Authorization: TD1 $INPUT_API_TOKEN")
​
  #response is a json with the project id in it. Here's some akward pure shell to extract it
  #Note: this code assumes the json object will always have its fields in the same order
  pjid=${resp#*"id"} #cut out everything before "id" (project id follows)
  pjid=${pjid%%"name"*} #cut out everything after "name" (next json item)
  len_m1=$((${#pjid} - 6)) #find last index and cut away characters from back
  pjid=${pjid: 3:$len_m1} #cut out lingering junk from ends
}

#function to download a project archive to named directory ($2) given its project id ($1)
function pull_project_td(){
  echo ===pulling project with id $1 to directory $2
  curl --request GET "$INPUT_WF_ENDPOINT/api/projects/$1/archive" \
    --header "Authorization: TD1 $INPUT_API_TOKEN" > resp.tar.gz
  project_path=${GITHUB_WORKSPACE}/$2
  mkdir $project_path
  tar -xvzf resp.tar.gz -C "$project_path"
  rm resp.tar.gz
}

project_dirs=$(echo $INPUT_PROJ_DIRS | sed "s/|/ /g")
echo -e "===== Project Dirs $project_dirs"

for proj_dir in $project_dirs ;do
  get_project_id_from_name $proj_dir 
  pull_project_td $pjid $proj_dir 
done