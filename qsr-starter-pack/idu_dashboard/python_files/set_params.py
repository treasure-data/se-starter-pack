import digdag

def main(project_name, unification_id, sub, site): 
    print(project_name, unification_id, sub, site)
    if site == 'us': 
        api_endpoint =  "api.treasuredata.com"
        workflow_api_url =  "api-workflow.treasuredata.com"
        td_cdp_endpoint = "https://api-cdp.treasuredata.com"
    
    elif site == 'eu':
        api_endpoint = "api.eu01.treasuredata.com"
        workflow_api_url = "api-workflow.eu01.treasuredata.com"
        td_cdp_endpoint = "https://api-cdp.eu01.treasuredata.com"
    
    else: 
        api_endpoint = ''
        workflow_api_url = ''
        td_cdp_endpoint = ''

    digdag.env.store({
            "project_name": project_name, 
            "unification_project": project_name,
            "unification_id": unification_id,
            "canonical_id_col": unification_id,
            "sub": sub,
            "src_db": f"cdp_unification_{sub}",
            "reporting_db": f"analytics_{sub}",
            "sink_database": f"analytics_{sub}",
            "api_endpoint": api_endpoint, 
            "workflow_api_url": workflow_api_url, 
            "td_cdp_endpoint": td_cdp_endpoint
                      })


