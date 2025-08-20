#!/usr/bin/env python3
"""
Test script to debug GitHub repository ruleset creation
"""
import requests
import json
import os

def test_repository_info(token, owner, repo):
    """Get repository information to check ruleset eligibility"""
    url = f"https://api.github.com/repos/{owner}/{repo}"
    headers = {
        'Authorization': f'Bearer {token}',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28'
    }
    
    response = requests.get(url, headers=headers)
    print(f"Repository info status: {response.status_code}")
    
    if response.ok:
        repo_data = response.json()
        print(f"Repository: {repo_data['full_name']}")
        print(f"Private: {repo_data['private']}")
        print(f"Owner type: {repo_data['owner']['type']}")
        print(f"Permissions: {repo_data.get('permissions', 'Not available')}")
        print(f"Plan: {repo_data['owner'].get('plan', {}).get('name', 'Unknown')}")
        return repo_data
    else:
        print(f"Failed to get repo info: {response.text}")
        return None

def test_existing_rulesets(token, owner, repo):
    """Check existing rulesets"""
    url = f"https://api.github.com/repos/{owner}/{repo}/rulesets"
    headers = {
        'Authorization': f'Bearer {token}',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28'
    }
    
    response = requests.get(url, headers=headers)
    print(f"Existing rulesets status: {response.status_code}")
    
    if response.ok:
        rulesets = response.json()
        print(f"Existing rulesets: {len(rulesets)} found")
        for ruleset in rulesets:
            print(f"  - {ruleset.get('name', 'Unnamed')} (ID: {ruleset.get('id', 'Unknown')})")
        return rulesets
    else:
        print(f"Failed to get rulesets: {response.text}")
        return None

def test_user_permissions(token):
    """Check user permissions"""
    url = "https://api.github.com/user"
    headers = {
        'Authorization': f'Bearer {token}',
        'Accept': 'application/vnd.github+json'
    }
    
    response = requests.get(url, headers=headers)
    if response.ok:
        user_data = response.json()
        print(f"User: {user_data['login']}")
        print(f"Plan: {user_data.get('plan', {}).get('name', 'Unknown')}")
        return user_data
    else:
        print(f"Failed to get user info: {response.text}")
        return None

if __name__ == "__main__":
    # Test with your GitHub token and repository
    token = input("Enter your GitHub token: ").strip()
    owner = input("Enter repository owner: ").strip()
    repo = input("Enter repository name: ").strip()
    
    print("=== Testing GitHub Repository Ruleset Capabilities ===")
    print()
    
    print("1. Testing user permissions...")
    test_user_permissions(token)
    print()
    
    print("2. Testing repository information...")
    test_repository_info(token, owner, repo)
    print()
    
    print("3. Testing existing rulesets...")
    test_existing_rulesets(token, owner, repo)
    print()
    
    print("4. Testing ruleset creation (minimal)...")
    url = f"https://api.github.com/repos/{owner}/{repo}/rulesets"
    headers = {
        'Authorization': f'Bearer {token}',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
        'Content-Type': 'application/json'
    }
    
    # Minimal test ruleset
    test_ruleset = {
        "name": "Test Ruleset",
        "target": "branch", 
        "enforcement": "disabled",  # Start with disabled to avoid conflicts
        "conditions": {
            "ref_name": {
                "include": ["refs/heads/test-*"]
            }
        },
        "rules": [
            {
                "type": "deletion"
            }
        ]
    }
    
    print(f"POST {url}")
    print(f"Headers: {headers}")
    print(f"Payload: {json.dumps(test_ruleset, indent=2)}")
    
    response = requests.post(url, headers=headers, json=test_ruleset)
    print(f"Response status: {response.status_code}")
    print(f"Response: {response.text}")