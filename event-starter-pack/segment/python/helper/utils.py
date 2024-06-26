import json
import yaml

def convert_yaml_to_json(folder, file_name):
  yaml_file_path = f'{folder}/{file_name}'

  try:
    with open(yaml_file_path, 'r') as yaml_file:
      yaml_data = yaml.safe_load(yaml_file)

    output = json.dumps(yaml_data)
    return output
  except Exception as ex:
    raise Exception(f'Convert Yaml file to Json failed: {ex}')

