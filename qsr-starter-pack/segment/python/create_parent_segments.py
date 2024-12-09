import segment.python.api.ps as ps

# import yaml
import json
import pandas as pd
import segment.python.td as td
import segment.python.helper.global_var as g
from segment.python.helper.utils import convert_yaml_to_json

# def convert_yaml_to_json(folder, file_name):
#   yaml_file_path = f'{folder}/{file_name}'

#   try:
#     with open(yaml_file_path, 'r') as yaml_file:
#       yaml_data = yaml.safe_load(yaml_file)

#     output = json.dumps(yaml_data)
#     return output
#   except Exception as ex:
#     raise Exception(f'Convert Yaml file to Json failed: {ex}')


def check_and_create(body):
    # check if parent segment exists
    # if exists return the audience_id
    # else create the parent segment
    audience_id, name, message = ps.getParentSegment(body)
    if audience_id:
        return audience_id, name, message
    else:
        audience_id, name, message = ps.createParentSegment(body)
        return audience_id, name, message


def check_and_update(body):
    # check if parent segment exists
    # if exists return the audience_id
    # and update the parent segment
    audience_id, name, message = ps.getParentSegment(body)
    if audience_id:
        audience_id, name, message = ps.updateParentSegment(body, audience_id)
    else:
        raise Exception(
            f"name: {name} audience_id: {audience_id} does not exists. Update failed."
        )
    return audience_id, name, message


def delete_and_create(body):
    # check if parent segment exists
    # if exists return the audience_id
    # delete the parent segment
    # create the parent segmen
    audience_id, name, message = ps.getParentSegment(body)
    if audience_id:
        _audience_id, _name, _message = ps.deleteParentSegment(audience_id)
        audience_id, name, message = ps.createParentSegment(body)
    else:
        raise Exception(
            f"name: {name} audience_id: {audience_id} does not exists. Recreation failed."
        )
    return audience_id, name, message


def main(folder, file_name, database, table, parent_db, unification_id, run_type="create"):
    df_log = pd.DataFrame()
    body = convert_yaml_to_json(folder, file_name)
    print(parent_db)
    body_ = body.replace('gld_retail', f'{parent_db}')
    print(unification_id)
    body_ = body_.replace('retail_unification_id', f'{unification_id}')
    
    print(body_)
    if run_type == "create":
        audience_id, name, message = check_and_create(body_)
    elif run_type == "update":
        audience_id, name, message = check_and_update(body_)
    elif run_type == "recreate":
        audience_id, name, message = delete_and_create(body_)
    else:
        audience_id, name, message = (None, None, None)
    df_log["file"] = [file_name]
    df_log["audience_id"] = [audience_id]
    df_log["name"] = [name]
    df_log["status"] = [message]
    df_log["run_type"] = [run_type]
    df_log["created_time"] = [g.formatted_time]
    df_log["url"] = [g.td_cdp_endpoint]

    if file_name and audience_id and name:
        td.uploadDataToTD(df_log, database, table)

    if message not in ("created", "updated", "selected") or not audience_id:
        raise ValueError(
            f"{file_name} is not created or updated successfully: {message}"
        )
    else:
        print(f"{file_name} is created with audience_id = {audience_id}, name = {name}")
