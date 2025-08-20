#!/usr/bin/env python3
"""
Test script to verify the fixed ruleset creation
"""
import requests
import json

def test_create_ruleset():
    """Test creating a repository ruleset with the fixed configuration"""
    
    # You'll need to provide these
    token = input("Enter your GitHub token: ").strip()
    owner = input("Enter repository owner (e.g., vishalpatel2890): ").strip() 
    repo = input("Enter repository name (e.g., va-mavi): ").strip()
    
    url = f"https://api.github.com/repos/{owner}/{repo}/rulesets"
    
    headers = {
        'Authorization': f'Bearer {token}',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
        'Content-Type': 'application/json'
    }
    
    # Fixed ruleset configuration
    ruleset_data = {
        "name": "Enforce Branch Names",
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
            },
            {
                "type": "branch_name_pattern",
                "parameters": {
                    "operator": "regex",
                    "pattern": "^(feat|fix|hot)\\/[a-z0-9._-]+$",
                    "negate": False,
                    "name": "Enforce feature branch naming convention"
                }
            }
        ],
        "bypass_actors": []
    }
    
    print(f"Creating ruleset for {owner}/{repo}...")
    print(f"URL: {url}")
    print(f"Payload: {json.dumps(ruleset_data, indent=2)}")
    
    try:
        response = requests.post(url, headers=headers, json=ruleset_data, timeout=15)
        
        print(f"\nResponse status: {response.status_code}")
        print(f"Response body: {response.text}")
        
        if response.ok:
            result = response.json()
            print(f"\n✅ SUCCESS! Ruleset created:")
            print(f"  - ID: {result.get('id')}")
            print(f"  - Name: {result.get('name')}")
            print(f"  - Enforcement: {result.get('enforcement')}")
            return True
        else:
            print(f"\n❌ FAILED: {response.status_code}")
            try:
                error_data = response.json()
                print(f"Error: {error_data}")
            except:
                print(f"Raw error: {response.text}")
            return False
            
    except Exception as e:
        print(f"\n❌ Exception: {e}")
        return False

if __name__ == "__main__":
    print("=== Testing Fixed Ruleset Creation ===")
    success = test_create_ruleset()
    if success:
        print("\n🎉 Ruleset creation is now working!")
    else:
        print("\n💥 Ruleset creation still failing")