import json
import requests
import pandas as pd
import segment.python.helper.global_var as g


def getFolders(audienceId):
  try:
    URL = f'{g.td_cdp_endpoint}/audiences/{audienceId}/folders'
    response = requests.get(URL, headers=g.headers)
    response.raise_for_status()
    data = response.json()
    if response.ok:
      df_folder = pd.json_normalize(data)
      df_folder  = df_folder[['id', 'name', 'parentFolderId', 'description']]
      df_folder['parentFolderId'] = df_folder['parentFolderId'].fillna('0')
      df_folder['type'] = 'folder-segment'

      return df_folder,'ok'
  except Exception as ex:
    print(f"GET API Folder failed: {response.text}")
    # raise Exception(f'GET API Folder failed: {ex}')
    return None,{response.text}


def createFolder(folder):
  name = folder['name'].values[0]
  print(f'createFolder:{name}')
  folder_id = folder['id'].values[0]
  # description = folder['description'].values[0]
  description = ''
  parentFolderId = folder['parentFolderId'].values[0] if folder['parentFolderId'].values[0] != 0 else None

  body = {
      "id": folder_id,
      "type": "folder-segment",
      "attributes": {
          "name": name,
          "description": description
      },
      "relationships": {
          "parentFolder": {
              "data": {
                  "id": parentFolderId,
                  "type": "folder-segment"
              }
          }
      }
  }
  body_str = json.dumps(body)
  # print(body_str)
  try:
    URL = f'{g.td_cdp_endpoint}/entities/folders/'
    response = requests.post(URL, data=body_str, headers=g.headers)
    response.raise_for_status()
    data = response.json()
    if response.ok:
      return data['data']['id'],'created'
  except Exception as ex:
    print(f'POST CreateFolder failed: {response.text}')
    return None, response.text


def getObjectsFolder(folder_id):
  try:
    URL = f'{g.td_cdp_endpoint}/entities/by-folder/{folder_id}?depth=10'
    response = requests.get(URL, headers=g.headers)
    response.raise_for_status()
    if response.ok:
      data = json.loads(response.text)
      df_objects = pd.json_normalize(data['data'],max_level=4)
      #check root folder
      if 'relationships.parentFolder.data.id' in df_objects.columns:
        df_objects = df_objects[['id', 'type','attributes.name', 'relationships.parentFolder.data.id']]
        df_objects.columns = ['id', 'type','name', 'parentFolderId']
      else:
        df_objects = df_objects[['id', 'type', 'attributes.name']]
        df_objects.columns = ['id', 'type', 'name']
        df_objects['parentFolderId'] = ['0']
      
      df_objects['parentFolderId'] = df_objects['parentFolderId'].fillna('0')
      return df_objects,'ok'
  except Exception as ex:
    print(f"getObjectsFolder failed: {response.text}")
    # raise Exception(f'getObjectsFolder failed: {ex}')
    return None,response.text


def deleteFolder(folder, df):
  try:
    URL = f'{g.td_cdp_endpoint}/entities/folders/{folder["id"]}'
    response = requests.delete(URL, headers=g.headers)
    response.raise_for_status()
    if response.ok:
      df = df[df['id'] != folder['id']]
      return df, 'success'
  except Exception as ex:
    print(f"deleteFolder failed: {response.text}")
    # raise Exception(f'deleteFolder failed: {ex}')
    return df, f'delete {folder["name"]} error: {response.text}'


def renameFolder(folder):
  # print(f"renameFolder:{folder['name']} -> {folder['new_name']}")
  folder_id = folder['id']
  name = folder['new_name']
  description = folder['description']
  parentFolderId = folder['parentFolderId'] if folder['parentFolderId'] != "0" else None

  body = {
      "id": folder_id,
      "type": "folder-segment",
      "attributes": {
          "name": name,
          "description": description
      },
      "relationships": {
          "parentFolder": {
              "data": {
                  "id": parentFolderId,
                  "type": "folder-segment"
              }
          }
      }
  }

  body_str = json.dumps(body)

  # print(body_str)
  try:
    URL = f'{g.td_cdp_endpoint}/entities/folders/{folder_id}'
    response = requests.patch(URL, data=body_str, headers=g.headers)
    response.raise_for_status()
    # data = response.json()
    if response.ok:
      print('renamed')
      return 'success'
  except Exception as ex:
    print(f"RenameFolder failed: {response.text}")
    # raise Exception(f'RenameFolder failed: {ex}')
    return response.text