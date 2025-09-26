#!/usr/bin/env python3
"""
Test what ruleset capabilities are available for a repository
"""

import requests
import json

def check_repository_capabilities():
    token = input("Enter your GitHub personal access token: ").strip()
    owner = input("Enter repository owner: ").strip() 
    repo = input("Enter repository name: ").strip()
    
    headers = {
        'Authorization': f'Bearer {token}',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28'
    }
    
    # Check repository details
    print("=== Repository Information ===")
    repo_url = f"https://api.github.com/repos/{owner}/{repo}"
    try:
        response = requests.get(repo_url, headers=headers, timeout=10)
        if response.ok:
            repo_data = response.json()
            print(f"Repository: {repo_data.get('full_name')}")
            print(f"Private: {repo_data.get('private')}")
            print(f"Owner type: {repo_data.get('owner', {}).get('type')}")
            print(f"Default branch: {repo_data.get('default_branch')}")
            
            # Check if it's a personal or organization repo
            if repo_data.get('owner', {}).get('type') == 'Organization':
                print("✅ Organization repository (may have advanced features)")
            else:
                print("ℹ️ Personal repository (may have limited features)")
        else:
            print(f"❌ Failed to get repo info: {response.status_code}")
            return
    except Exception as e:
        print(f"❌ Error: {e}")
        return
    
    # Check existing rulesets
    print("\n=== Existing Rulesets ===")
    rulesets_url = f"https://api.github.com/repos/{owner}/{repo}/rulesets"
    try:
        response = requests.get(rulesets_url, headers=headers, timeout=10)
        print(f"GET {rulesets_url}")
        print(f"Status: {response.status_code}")
        
        if response.ok:
            rulesets = response.json()
            print(f"Existing rulesets: {len(rulesets)}")
            for ruleset in rulesets:
                print(f"  - {ruleset.get('name')} (ID: {ruleset.get('id')}, Enforcement: {ruleset.get('enforcement')})")
        else:
            print(f"Response: {response.text}")
            if response.status_code == 404:
                print("ℹ️ Rulesets may not be available for this repository")
            elif response.status_code == 403:
                print("ℹ️ Insufficient permissions or feature not available")
    except Exception as e:
        print(f"❌ Error checking rulesets: {e}")
    
    # Test basic ruleset creation (non_fast_forward only)
    print("\n=== Testing Basic Ruleset Creation ===")
    basic_ruleset = {
        "name": "Test Basic Protection",
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
                "type": "non_fast_forward"
            }
        ],
        "bypass_actors": []
    }
    
    try:
        response = requests.post(rulesets_url, headers=headers, json=basic_ruleset, timeout=15)
        print(f"Basic ruleset creation: {response.status_code}")
        
        if response.ok:
            ruleset_data = response.json()
            ruleset_id = ruleset_data.get('id')
            print(f"✅ Basic ruleset created successfully (ID: {ruleset_id})")
            
            # Clean up
            delete_url = f"{rulesets_url}/{ruleset_id}"
            delete_response = requests.delete(delete_url, headers=headers, timeout=10)
            if delete_response.ok:
                print(f"✅ Cleaned up test ruleset")
            else:
                print(f"⚠️ Failed to clean up: {delete_response.status_code}")
        else:
            print(f"❌ Basic ruleset failed: {response.status_code}")
            print(f"Response: {response.text}")
    except Exception as e:
        print(f"❌ Error testing basic ruleset: {e}")

if __name__ == "__main__":
    check_repository_capabilities()