import pandas as pd
import segment.python.td as td
from segment.python.helper.utils import convert_yaml_to_json
import segment.python.api.folder as folder_api
import segment.python.api.segment as segment_api
import segment.python.helper.global_var as g
import json


def main(folder, file_name, database, table, audience_id):
    df_log = pd.DataFrame()
    df_folder, status = folder_api.getFolders(audience_id)
    rootfolder_id = df_folder[df_folder["parentFolderId"] == "0"][["id"]].values[0][0]
    _json = convert_yaml_to_json(folder, file_name)
    _json = _json.replace("${rootfolder_id}", rootfolder_id).replace(
        "${audience_id}", str(audience_id)
    )
    data = json.loads(_json)
    attribute_len = len(data["attributes"])
    #iterate over the attributes to generate all the segments
    for i in range(attribute_len):
        new_segment_dict = {}
        for key, value in data.items():
            if key != "attributes":
                new_segment_dict[key] = value
            elif key == "attributes":
                new_segment_dict[key] = value[i]
        res, status = segment_api.createSegment(new_segment_dict)
        
        if status == "success":
          print(f"Segment created successfully for {new_segment_dict['attributes']['name']} with id {res}")
          df_log = pd.concat(
                [
                    df_log,
                    pd.DataFrame(
                        [
                            {
                                "file": file_name,
                                "audience_id": audience_id,
                                "name": new_segment_dict["attributes"]["name"],
                                "status": status,
                                "created_time": g.formatted_time,
                                "url": g.td_cdp_endpoint,
                            }
                        ]
                    ),
                ]
            )
        else:
            try:
                err_dict = json.loads(status)
                if err_dict["errors"]["name"][0] != "has already been taken":
                    df_log = pd.concat(
                        [
                            df_log,
                            pd.DataFrame(
                                [
                                    {
                                        "file": file_name,
                                        "audience_id": audience_id,
                                        "name": new_segment_dict["attributes"]["name"],
                                        "status": status,
                                        "created_time": g.formatted_time,
                                        "url": g.td_cdp_endpoint,
                                    }
                                ]
                            ),
                        ]
                    )
                    raise Exception(f"Segment creation failed : {status}")
                else:
                    df_log = pd.concat(
                        [
                            df_log,
                            pd.DataFrame(
                                [
                                    {
                                        "file": file_name,
                                        "audience_id": audience_id,
                                        "name": new_segment_dict["attributes"]["name"],
                                        "status": "segment name already exists.",
                                        "created_time": g.formatted_time,
                                        "url": g.td_cdp_endpoint,
                                    }
                                ]
                            ),
                        ]
                    )
                    print(f"Segment already exists for {new_segment_dict['attributes']['name']}")
            except Exception as err:
                td.uploadDataToTD(df_log, database, table)
                raise Exception(
                    f"Segment creation failed : {status} additional error {err}"
                )
    td.uploadDataToTD(df_log, database, table)
