import json
import pytd
import pandas as pd
import segment.python.helper.global_var as g


def uploadDataToTD(data, td_write_db, td_write_table, exists="append"):
    print(g.td_api_key)
    try:
        client = pytd.Client(
            apikey=g.td_api_key,
            endpoint=g.td_endpoint_base,
            database=td_write_db,
            default_engine="presto",
        )
    except BaseException:
        raise Exception("Error calling pytd.Client")

    try:
        client.load_table_from_dataframe(
            data, td_write_table, writer="bulk_import", if_exists=exists
        )
    except BaseException:
        raise Exception("Error writing table back into TD Database")
