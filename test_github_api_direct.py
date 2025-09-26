#!/usr/bin/env python3
"""
Direct test of GitHub Rulesets API with different approaches
"""

import requests
import json
import sys

def test_github_api_approaches():
    token = input("Enter your GitHub personal access token: ").strip()
    owner = input("Enter repository owner: ").strip()
    repo = input("Enter repository name: ").strip()
    
    url = f"https://api.github.com/repos/{owner}/{repo}/rulesets"
    
    headers = {
        'Authorization': f'Bearer {token}',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
        'Content-Type': 'application/json'
    }
    
    # Test different approaches for branch naming
    
    # Approach 1: Using regex operator
    approach1 = {
        "name": "Test Branch Names - Regex",
        "target": "branch",
        "enforcement": "active",
        "conditions": {
            "ref_name": {
                "exclude": ["refs/heads/main"],
                "include": ["~ALL"]
            }
        },
        "rules": [
            {
                "type": "branch_name_pattern",
                "parameters": {
                    "operator": "regex",
                    "pattern": "^(feat|fix|hot)/[a-z0-9._-]+$",
                    "negate": False
                }
            }
        ],
        "bypass_actors": []
    }
    
    # Approach 2: Using starts_with operator  
    approach2 = {
        "name": "Test Branch Names - Starts With",
        "target": "branch", 
        "enforcement": "active",
        "conditions": {
            "ref_name": {
                "exclude": ["refs/heads/main"],
                "include": ["~ALL"]
            }
        },
        "rules": [
            {
                "type": "branch_name_pattern",
                "parameters": {
                    "operator": "starts_with",
                    "pattern": "feat/",
                    "negate": False
                }
            }
        ],
        "bypass_actors": []
    }
    
    # Approach 3: Check if rule type exists - get repository info
    print("First, let's check the repository rulesets capability...")
    repo_url = f"https://api.github.com/repos/{owner}/{repo}"
    try:
        repo_response = requests.get(repo_url, headers=headers, timeout=10)
        if repo_response.ok:
            repo_data = repo_response.json()
            print(f"Repository: {repo_data.get('full_name')}")
            print(f"Default branch: {repo_data.get('default_branch')}")
            print(f"Private: {repo_data.get('private')}")
        else:
            print(f"Failed to get repo info: {repo_response.status_code}")
    except Exception as e:
        print(f"Error getting repo info: {e}")
    
    approaches = [
        ("Regex Pattern", approach1),
        ("Starts With Pattern", approach2)
    ]
    
    created_rulesets = []
    
    for name, ruleset_data in approaches:
        print(f"\n--- Testing {name} ---")
        print(f"Payload: {json.dumps(ruleset_data, indent=2)}")
        
        try:
            response = requests.post(url, headers=headers, json=ruleset_data, timeout=15)
            print(f"Status: {response.status_code}")
            print(f"Response: {response.text}")
            
            if response.ok:
                ruleset_id = response.json().get('id')
                print(f"✅ {name} ruleset created with ID: {ruleset_id}")
                created_rulesets.append((name, ruleset_id))
            else:
                print(f"❌ {name} failed: {response.status_code}")
                if response.headers.get('content-type', '').startswith('application/json'):
                    try:
                        error_data = response.json()
                        print(f"Error details: {json.dumps(error_data, indent=2)}")
                    except:
                        pass
                        
        except Exception as e:
            print(f"❌ Error testing {name}: {e}")
    
    # Clean up
    if created_rulesets:
        print("\n--- Cleaning up test rulesets ---")
        for name, ruleset_id in created_rulesets:
            delete_url = f"{url}/{ruleset_id}"
            try:
                delete_response = requests.delete(delete_url, headers=headers, timeout=10)
                if delete_response.ok:
                    print(f"✅ Deleted {name} (ID: {ruleset_id})")
                else:
                    print(f"⚠️ Failed to delete {name}: {delete_response.status_code}")
            except Exception as e:
                print(f"⚠️ Error deleting {name}: {e}")
    
    print(f"\n--- Summary ---")
    print(f"Repository: {owner}/{repo}")
    if created_rulesets:
        print("✅ At least one approach worked - branch name patterns are supported")
    else:
        print("❌ No approaches worked - branch name patterns may not be supported")

if __name__ == "__main__":
    test_github_api_approaches()