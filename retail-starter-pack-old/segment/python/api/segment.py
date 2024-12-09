import json
import requests
import segment.python.helper.global_var as g


def extract_ref_segment_ids(error_json):
  errors = json.loads(error_json)
  errors = errors['errors']
  for error in errors:
    if 'meta' in error and 'referencedBySegments' in error['meta']:
        # extract the list of segment IDs
        segment_ids = [segment['id'] for segment in error['meta']['referencedBySegments']]
        return segment_ids
  return []

def createSegment(sm_json):
  print("createSegment:")
  try:
    URL = f'{g.td_cdp_endpoint}/entities/segments'
    response = requests.post(URL, headers=g.headers, data=json.dumps(sm_json))
    response.raise_for_status()
    if response.ok:
      data = json.loads(response.text)
      return data["data"]["id"], 'success'
  except Exception as ex:
    print(f"createSegment exception raised: {response.text}")
    # raise Exception(f'createSegment failed: {ex}')
    return None, response.text


def createPredictiveSegment(sm_json):
  try:
    URL = f'{g.td_cdp_endpoint}/entities/predictive_segments'
    response = requests.post(URL, headers=g.headers, data=json.dumps(sm_json))
    response.raise_for_status()
    if response.ok:
      data = json.loads(response.text)
      return data["data"]["id"], 'success'
  except Exception as ex:
    print(f"createPredictiveSegment failed: {response.text}")
    # raise Exception(f'createPredictiveSegment failed: {ex}')
    return None, response.text


def getSegment(segmentId):
  try:
    URL = f'{g.td_cdp_endpoint}/entities/segments/{segmentId}'
    response = requests.get(URL, headers=g.headers)
    response.raise_for_status()
    if response.ok:
      data = json.loads(response.text)
      data = data['data']
      return data
  except Exception as ex:
    print(f"getSegment failed: {response.text}")
    raise Exception(f'getSegment failed: {ex}')

def getPredictiveSegment(segmentId):
  try:
    URL = f'{g.td_cdp_endpoint}/entities/predictive_segments/{segmentId}'
    response = requests.get(URL, headers=g.headers)
    response.raise_for_status()
    if response.ok:
      data = json.loads(response.text)
      data = data['data']
      return data
  except Exception as ex:
    print(f"getPredictiveSegment failed: {response.text}")
    raise Exception(f'getPredictiveSegment failed: {ex}')

def updateSegment(sm_json, segment_id):
  print("updateSegment:")
  try:
    URL = f'{g.td_cdp_endpoint}/entities/segments/{segment_id}'
    response = requests.patch(URL, headers=g.headers, data=json.dumps(sm_json))
    response.raise_for_status()
    if response.ok:
      data = json.loads(response.text)
      return data["data"]["id"], 'updated'
  except Exception as ex:
    print(f"updateSegment failed: {response.text}")
    # raise Exception(f'updateSegment failed: {ex}')
    return None, response.text

def updatePredictiveSegment(sm_json,segment_id):
  try:
    URL = f'{g.td_cdp_endpoint}/entities/predictive_segments/{segment_id}'
    response = requests.patch(URL, headers=g.headers, data=json.dumps(sm_json))
    response.raise_for_status()
    if response.ok:
      data = json.loads(response.text)
      return data["data"]["id"], 'updated'
  except Exception as ex:
    print(f"updatePredictiveSegment failed: {response.text}")
    # raise Exception(f'updatePredictiveSegment failed: {ex}')
    return None, response.text


def deleteSegment(segment_id):
  print(f'deleteSegment:{segment_id}')
  
  try:
    URL = f'{g.td_cdp_endpoint}/entities/segments/{segment_id}'
    response = requests.delete(URL, headers=g.headers)
    response.raise_for_status()
    if response.ok:
      return [],'success';
  except Exception as ex:
    print(f"deleteSegment failed: {response.text}")
    segment_ids = extract_ref_segment_ids(response.text)
    return segment_ids, f'{response.text}'

def deletePredictiveSegment(segment_id):
  print(f'deletePredictiveSegment:{segment_id}')
  try:
    URL = f'{g.td_cdp_endpoint}/entities/predictive_segments/{segment_id}'
    response = requests.delete(URL, headers=g.headers)
    response.raise_for_status()
    if response.ok:
      return 'success'
  except Exception as ex:
    print(f"deletePredictiveSegment failed: {response.text}")
    # raise Exception(f'deletePredictiveSegment failed: {ex}')
    return f'Deletion unsuccessful: {response.text}'