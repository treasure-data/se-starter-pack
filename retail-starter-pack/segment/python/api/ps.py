import json
import requests
import python.helper.global_var as g


def createParentSegment(body):
  try:
    URL = f'{g.td_cdp_endpoint}/audiences'
    response = requests.post(URL, data=body, headers=g.headers)
    data = json.loads(response.text)
    response.raise_for_status()
    if response.ok:
      return data.get("id"), data.get("name"), 'created'
  except Exception as ex:
    # print(f"Post API create Parent Segment failed: {response.text}")
    # raise Exception(f'Post API create Parent Segment failed: {ex}')
    print(str(ex), URL, body, response.text)

def updateParentSegment(body, id):
  try:
    URL = f'{g.td_cdp_endpoint}/audiences/{id}'
    response = requests.put(URL, data=body, headers=g.headers)
    data = json.loads(response.text)
    response.raise_for_status()
    if response.ok:
      return data.get("id"), data.get("name"), 'updated'
  except Exception as ex:
    # print(f"Post API create Parent Segment failed: {response.text}")
    # raise Exception(f'Post API create Parent Segment failed: {ex}')
    print(str(ex), URL, body, response.text)

def deleteParentSegment(id):
  try:
    URL = f'{g.td_cdp_endpoint}/audiences/{id}'
    response = requests.delete(URL, headers=g.headers)
    data = json.loads(response.text)
    response.raise_for_status()
    if response.ok:
      return data.get("id"), data.get("name"), 'deleted'
  except Exception as ex:
    # print(f"Post API create Parent Segment failed: {response.text}")
    # raise Exception(f'Post API create Parent Segment failed: {ex}')
    print(str(ex), URL, None, response.text)

def getParentSegment(body):
  
  try:
    URL = f'{g.td_cdp_endpoint}/audiences'
    response = requests.get(URL, headers=g.headers)
    data = json.loads(response.text)
    _body = json.loads(body)
    print(_body)
    response.raise_for_status()
    if response.ok:
      for row in data:
        print(row['id'])
        print(_body['id'])
        if str(row['id']) == str(_body['id']):
          print(f"Found Parent Segment {row.get('id')}")
          return row.get("id"), row.get("name"), 'selected'
      # No Matches
      print(f"Not Found Parent Segment {_body['id']}")
      return None, None, 'selected'
  except Exception as ex:
    # print(f"Post API create Parent Segment failed: {response.text}")
    # raise Exception(f'Post API create Parent Segment failed: {ex}')
    print(str(ex), URL, None, response.text)