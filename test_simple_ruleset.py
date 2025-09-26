#!/usr/bin/env python3
"""
Simple test to check what ruleset rule types are supported.
"""

import requests
import json
import os

def test_simple_ruleset():
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
    
    # Test 1: Very basic ruleset with just non_fast_forward
    basic_ruleset = {
        "name": "Test - Basic Protection",
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
    
    print("Testing basic ruleset...")
    print(f"URL: {url}")
    print(f"Data: {json.dumps(basic_ruleset, indent=2)}")
    
    try:
        response = requests.post(url, headers=headers, json=basic_ruleset, timeout=15)
        print(f"Status: {response.status_code}")
        print(f"Response: {response.text}")
        
        if response.ok:
            ruleset_id = response.json().get('id')
            print(f"✅ Basic ruleset created with ID: {ruleset_id}")
            
            # Clean up
            delete_url = f"{url}/{ruleset_id}"
            delete_response = requests.delete(delete_url, headers=headers, timeout=15)
            if delete_response.ok:
                print(f"✅ Cleaned up test ruleset")
            else:
                print(f"⚠️ Failed to clean up test ruleset: {delete_response.status_code}")
        else:
            print(f"❌ Basic ruleset failed: {response.status_code}")
            
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    test_simple_ruleset()