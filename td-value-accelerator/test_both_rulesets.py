#!/usr/bin/env python3
"""
Test both basic and advanced rulesets to determine repository capabilities
"""
import requests
import json

def test_basic_ruleset(token, owner, repo):
    """Test basic ruleset creation"""
    url = f"https://api.github.com/repos/{owner}/{repo}/rulesets"
    headers = {
        'Authorization': f'Bearer {token}',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
        'Content-Type': 'application/json'
    }
    
    basic_ruleset = {
        "name": "Basic Branch Protection Test",
        "target": "branch",
        "enforcement": "disabled",  # Start disabled to avoid conflicts
        "conditions": {
            "ref_name": {
                "exclude": ["refs/heads/main"],
                "include": ["refs/heads/test-*"]  # Only apply to test branches
            }
        },
        "rules": [
            {
                "type": "non_fast_forward"
            }
        ],
        "bypass_actors": []
    }
    
    print("=== Testing Basic Ruleset ===")
    print(f"URL: {url}")
    print(f"Payload: {json.dumps(basic_ruleset, indent=2)}")
    
    response = requests.post(url, headers=headers, json=basic_ruleset, timeout=15)
    print(f"Response status: {response.status_code}")
    
    if response.ok:
        result = response.json()
        print(f"✅ Basic ruleset created successfully!")
        print(f"ID: {result.get('id')}")
        return result.get('id')
    else:
        print(f"❌ Basic ruleset failed: {response.text}")
        return None

def test_advanced_ruleset(token, owner, repo):
    """Test advanced ruleset with branch_name_pattern"""
    url = f"https://api.github.com/repos/{owner}/{repo}/rulesets"
    headers = {
        'Authorization': f'Bearer {token}',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
        'Content-Type': 'application/json'
    }
    
    advanced_ruleset = {
        "name": "Advanced Branch Protection Test",
        "target": "branch",
        "enforcement": "disabled",  # Start disabled
        "conditions": {
            "ref_name": {
                "exclude": ["refs/heads/main"],
                "include": ["refs/heads/feature-*"]  # Only feature branches
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
                    "pattern": "^feature\\/[a-z0-9._-]+$",
                    "negate": False,
                    "name": "Test branch naming"
                }
            }
        ],
        "bypass_actors": []
    }
    
    print("\n=== Testing Advanced Ruleset (with branch_name_pattern) ===")
    print(f"URL: {url}")
    print(f"Payload: {json.dumps(advanced_ruleset, indent=2)}")
    
    response = requests.post(url, headers=headers, json=advanced_ruleset, timeout=15)
    print(f"Response status: {response.status_code}")
    
    if response.ok:
        result = response.json()
        print(f"✅ Advanced ruleset created successfully!")
        print(f"ID: {result.get('id')}")
        return result.get('id')
    else:
        print(f"❌ Advanced ruleset failed: {response.text}")
        try:
            error_data = response.json()
            print(f"Error details: {error_data}")
        except:
            pass
        return None

def cleanup_test_rulesets(token, owner, repo, ruleset_ids):
    """Clean up test rulesets"""
    print(f"\n=== Cleaning up test rulesets ===")
    for ruleset_id in ruleset_ids:
        if ruleset_id:
            url = f"https://api.github.com/repos/{owner}/{repo}/rulesets/{ruleset_id}"
            headers = {
                'Authorization': f'Bearer {token}',
                'Accept': 'application/vnd.github+json',
                'X-GitHub-Api-Version': '2022-11-28'
            }
            
            response = requests.delete(url, headers=headers, timeout=10)
            if response.ok:
                print(f"✅ Deleted test ruleset {ruleset_id}")
            else:
                print(f"⚠️ Could not delete test ruleset {ruleset_id}: {response.status_code}")

if __name__ == "__main__":
    print("=== Repository Ruleset Capability Test ===")
    
    token = input("Enter your GitHub token: ").strip()
    owner = input("Enter repository owner: ").strip()
    repo = input("Enter repository name: ").strip()
    
    created_rulesets = []
    
    # Test basic ruleset
    basic_id = test_basic_ruleset(token, owner, repo)
    if basic_id:
        created_rulesets.append(basic_id)
    
    # Test advanced ruleset  
    advanced_id = test_advanced_ruleset(token, owner, repo)
    if advanced_id:
        created_rulesets.append(advanced_id)
    
    # Summary
    print(f"\n=== Summary ===")
    if basic_id and advanced_id:
        print("✅ Repository supports both basic and advanced rulesets!")
        print("✅ branch_name_pattern rules are supported")
    elif basic_id and not advanced_id:
        print("⚠️ Repository supports basic rulesets only")
        print("❌ branch_name_pattern rules are NOT supported")
        print("💡 This usually means the repository is on GitHub Free plan")
    elif not basic_id and not advanced_id:
        print("❌ Repository does not support rulesets")
        print("💡 Check if you have admin permissions")
    
    # Cleanup
    cleanup_response = input("\nDelete test rulesets? (y/n): ").strip().lower()
    if cleanup_response == 'y':
        cleanup_test_rulesets(token, owner, repo, created_rulesets)