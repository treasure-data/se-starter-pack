import os
from datetime import datetime

td_site = os.environ.get("TD_SITE")
td_api_key = os.environ["TD_API_KEY"]

# print(td_api_key)

headers = {"Authorization": f"TD1 {td_api_key}", "Content-Type": "application/json"}


# log
current_time = datetime.now()
formatted_time = current_time.strftime("%Y-%m-%d %H:%M:%S")


# api key
td_endpoint_base = "https://api.eu01.treasuredata.com"
td_cdp_endpoint = "https://api-cdp.eu01.treasuredata.com"

if td_site == "eu":
    td_endpoint_base = "https://api.eu01.treasuredata.com"
    td_cdp_endpoint = "https://api-cdp.eu01.treasuredata.com"
elif td_site == "ap":
    td_endpoint_base = "https://api.ap02.treasuredata.com"
    td_cdp_endpoint = "https://api-cdp.ap02.treasuredata.com"
elif td_site == "us":
    td_endpoint_base = "https://api.treasuredata.com"
    td_cdp_endpoint = "https://api-cdp.treasuredata.com"
elif td_site == "jp":
    td_endpoint_base = "https://api.treasuredata.co.jp"
    td_cdp_endpoint = "https://api-cdp.treasuredata.co.jp"
else:
    raise ValueError(f"Unsupported TD_SITE value: {td_site}")
