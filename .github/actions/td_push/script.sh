#Create a tarball from the file in the path given as $1.
#Code originally lifted from the hello fresh repository
#$1: workflow directory in the github workspace
#The options given to the "tar" function cause it to change to the wf_path directory and create a new file
#with $1 as a name.
#GITHUB_WORKSPACE is an global environment variable that refers to the default repository directory
function create_tarball() {
  echo -e "===== Creating tarball file $1.tar.gz"
  wf_path=${GITHUB_WORKSPACE}/$1
  tar -cvzf "$1.tar.gz" -C "$wf_path" $(ls "$wf_path") || exit 1
} >&2

#Push a project to TD, assuming the tarball has been created first
#i.e. create_tarball "proj_dir" "proj" ; push_workflow "proj"
#Code originally lifted from the hello fresh repository
#$1: The name of the project previously made into a tarball
#$2: The name of the current branch being used to label the project
#$3: the TD api access token
#$4: The TD api endpoint (eu01, ap02). Can vary by region
#$5: The TD environment (ie dev, qa). Adds another part to the project label (projname_qa_f1234). Use "NULL" for none
#curl details: "w-" prints the http code (400, 404, et). --request is used to make an explicit request type
#
function push_workflow_td() {

  #Include the revision parameter and format the version as "${INPUT_FBRANCH}_${GITHUB_SHA}_${EPOCHSECONDS}"
  if [[ $INPUT_DPLY_VERSION == '' ]]; then
    project_rev="$INPUT_FBRANCH"_"$INPUT_CURR_SHA"_"$(date +%s)"
  else
    project_rev=$(echo $INPUT_DPLY_VERSION | sed "s/\./_/g")
  fi

  #Determine the project name
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

  #how to make a put request is documented here:
  #https://td-internal.redoc.ly/pages/td-digdag-sever_v1-private/operation/putProject/
  #Notable is that the revision in the url is REQUIRED
  echo "===== Sending project $td_project_name with revision $project_rev with endpoint $INPUT_WF_ENDPOINT data ${GITHUB_WORKSPACE}/$1.tar.gz"
  status_code=$(curl -s -o /dev/null -w "%{http_code}" \
    --request PUT "$INPUT_WF_ENDPOINT/api/projects?project=$td_project_name&revision=$project_rev" \
    --header "Authorization: TD1 $INPUT_API_TOKEN" \
    --header "Content-Type: application/gzip" \
    --data-binary "@${GITHUB_WORKSPACE}/$2.tar.gz")

  #Here's some boilerplate to deal with the status code
  echo -e "===== Response status code $status_code"
  unaccepted_status_code_regex='^4[0-9]{2}|5[0-9]{2}'
  if [[ "$status_code" =~ $unaccepted_status_code_regex ]]; then
    exit 1
  fi
  #warning that TD will still return code 200 if the workflow was pushed, but the workflow's code had errors and could not be validated
  #the unvalidated workflow will not show up as a project update in this case
} >&2

#run git diff to find which project files were actually changed since the last push
#--name-only gives us just the names of the files instead of a bunch of stats with each
#--diff-filter ensures only files that were definitely changed make it in
#cut -d '/' selects the topmost directory of the file only, which should be the project directory
#sort + uniq removes any duplicates, so that repeat directories are not used
if [[ $INPUT_PREV_SHA == '' ]]; then
  changed_dirs=$(echo $INPUT_PROJ_DIRS | sed "s/|/ /g")
else
  changed_dirs=$(git diff --name-only --diff-filter=ACMRT $INPUT_PREV_SHA $INPUT_CURR_SHA | cut -d '/' -f1 | sort | uniq)
fi

echo -e "===== Changed Dirs $changed_dirs"
#proj_dirs looks like abc|def|xyz, perfect form for a regex
dir_regex="^($INPUT_PROJ_DIRS)"
echo -e "===== dir_regex $dir_regex"
for proj_dir in $changed_dirs; do
  echo -e "===== proj_dir $proj_dir"
  if [[ $proj_dir =~ $dir_regex ]]; then
    echo -e "===== proj_dir $proj_dir dir_regex $dir_regex "
    create_tarball $proj_dir
    push_workflow_td $INPUT_PROJ_NAME $proj_dir
  fi
done
echo -e "===== Done ====="
