#!/usr/bin/env python3
"""
Test script to validate GitHub repository ruleset capabilities.
Tests both branch naming enforcement and main branch protection.
"""

import requests
import json
import os
import sys
from typing import Dict, Any, List

def get_github_token():
    """Get GitHub token from environment or user input"""
    token = os.getenv('GITHUB_TOKEN')
    if not token:
        token = input("Enter your GitHub personal access token: ").strip()
    return token

def test_ruleset_creation(token: str, owner: str, repo: str, ruleset_data: Dict[str, Any]) -> Dict[str, Any]:
    """Test creating a specific ruleset"""
    url = f"https://api.github.com/repos/{owner}/{repo}/rulesets"
    
    headers = {
        'Authorization': f'Bearer {token}',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
        'Content-Type': 'application/json'
    }
    
    try:
        response = requests.post(url, headers=headers, json=ruleset_data, timeout=15)
        
        result = {
            'status_code': response.status_code,
            'success': response.ok,
            'response': response.json() if response.headers.get('content-type', '').startswith('application/json') else response.text
        }
        
        if response.ok:
            result['ruleset_id'] = result['response'].get('id')
            
        return result
        
    except requests.exceptions.RequestException as e:
        return {
            'status_code': 0,
            'success': False,
            'error': str(e)
        }

def delete_ruleset(token: str, owner: str, repo: str, ruleset_id: int) -> bool:
    """Delete a ruleset by ID"""
    url = f"https://api.github.com/repos/{owner}/{repo}/rulesets/{ruleset_id}"
    
    headers = {
        'Authorization': f'Bearer {token}',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28'
    }
    
    try:
        response = requests.delete(url, headers=headers, timeout=15)
        return response.ok
    except:
        return False

def test_repository_rulesets(token: str, owner: str, repo: str):
    """Test both branch naming and main branch protection rulesets"""
    
    print(f"Testing repository rulesets for {owner}/{repo}")
    print("=" * 60)
    
    # Test 1: Branch naming enforcement ruleset
    branch_naming_ruleset = {
        "name": "Test - Enforce Branch Names",
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
                    "pattern": "^(feat|fix|hot)/[a-z0-9._-]+$",
                    "negate": False,
                    "name": "Enforce feature branch naming convention"
                }
            }
        ],
        "bypass_actors": []
    }
    
    # Test 2: Main branch protection ruleset
    main_branch_ruleset = {
        "name": "Test - Main Branch Protection",
        "target": "branch",
        "enforcement": "active",
        "conditions": {
            "ref_name": {
                "exclude": [],
                "include": ["~DEFAULT_BRANCH"]
            }
        },
        "rules": [
            {
                "type": "deletion"
            },
            {
                "type": "pull_request",
                "parameters": {
                    "required_approving_review_count": 1,
                    "dismiss_stale_reviews_on_push": False,
                    "require_code_owner_reviews": True,
                    "require_last_push_approval": False,
                    "required_review_thread_resolution": False,
                    "automatic_copilot_code_review_enabled": False,
                    "allowed_merge_methods": [
                        "merge",
                        "squash",
                        "rebase"
                    ]
                }
            }
        ],
        "bypass_actors": []
    }
    
    rulesets_to_test = [
        ("Branch Naming Enforcement", branch_naming_ruleset),
        ("Main Branch Protection", main_branch_ruleset)
    ]
    
    created_rulesets = []
    
    # Test each ruleset
    for ruleset_name, ruleset_data in rulesets_to_test:
        print(f"\nTesting {ruleset_name}...")
        print("-" * 40)
        
        result = test_ruleset_creation(token, owner, repo, ruleset_data)
        
        if result['success']:
            print(f"✅ {ruleset_name} ruleset created successfully")
            print(f"   Ruleset ID: {result.get('ruleset_id')}")
            created_rulesets.append((ruleset_name, result.get('ruleset_id')))
        else:
            print(f"❌ {ruleset_name} ruleset failed")
            print(f"   Status Code: {result['status_code']}")
            if 'error' in result:
                print(f"   Error: {result['error']}")
            else:
                print(f"   Response: {json.dumps(result['response'], indent=2)}")
    
    # Clean up created rulesets
    if created_rulesets:
        print(f"\nCleaning up test rulesets...")
        print("-" * 40)
        
        for ruleset_name, ruleset_id in created_rulesets:
            if ruleset_id and delete_ruleset(token, owner, repo, ruleset_id):
                print(f"✅ Deleted {ruleset_name} (ID: {ruleset_id})")
            else:
                print(f"⚠️ Failed to delete {ruleset_name} (ID: {ruleset_id})")
    
    # Summary
    print(f"\nTest Summary")
    print("=" * 60)
    successful_tests = len([r for r in [test_ruleset_creation(token, owner, repo, rs[1]) for rs in rulesets_to_test] if r['success']])
    total_tests = len(rulesets_to_test)
    
    print(f"Repository: {owner}/{repo}")
    print(f"Successful ruleset creations: {successful_tests}/{total_tests}")
    
    if successful_tests == total_tests:
        print("✅ All rulesets can be created successfully")
        print("   Your repository supports both branch naming enforcement and main branch protection")
    elif successful_tests > 0:
        print("⚠️ Some rulesets can be created")
        print("   Your repository has partial ruleset support")
    else:
        print("❌ No rulesets can be created")
        print("   Your repository may not support advanced rulesets or you may lack permissions")
    
    return successful_tests == total_tests

def main():
    """Main function"""
    if len(sys.argv) != 3:
        print("Usage: python test_rulesets.py <owner> <repo>")
        print("Example: python test_rulesets.py myorg myrepo")
        sys.exit(1)
    
    owner = sys.argv[1]
    repo = sys.argv[2]
    
    token = get_github_token()
    if not token:
        print("❌ GitHub token is required")
        sys.exit(1)
    
    try:
        success = test_repository_rulesets(token, owner, repo)
        sys.exit(0 if success else 1)
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()