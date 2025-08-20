from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Dict, Any
import requests
import base64
import uuid
import threading

router = APIRouter()

# Progress tracking for file copy operations
copy_progress = {}  # Dict to store progress by session ID

# GitHub repository details
GITHUB_REPO_URL = "https://api.github.com/repos/treasure-data/se-starter-pack"
GITHUB_RAW_BASE = "https://raw.githubusercontent.com/treasure-data/se-starter-pack/main"

@router.get("/starter-packs")
async def get_starter_packs():
    """Get available starter packs from GitHub repository"""
    try:
        # For demo, return predefined starter packs
        return {
            "packs": [
                {
                    "id": "qsr",
                    "name": "QSR Starter Pack",
                    "description": "Quick Service Restaurant analytics and customer journey tracking",
                    "type": "QSR",
                    "path": "qsr-starter-pack",
                    "features": [
                        "Order analytics and sales trends",
                        "Customer journey mapping", 
                        "Marketing attribution",
                        "Cohort analysis",
                        "Segmentation and targeting",
                        "Dashboard templates"
                    ],
                    "workflows": [
                        "wf02_mapping.dig",
                        "wf03_validate.dig",
                        "wf04_stage.dig",
                        "wf05_unify.dig",
                        "wf06_golden.dig",
                        "wf07_analytics.dig",
                        "wf08_create_refresh_master_segment.dig"
                    ]
                },
                {
                    "id": "retail",
                    "name": "Retail Starter Pack",
                    "description": "Comprehensive retail analytics with customer insights and product performance",
                    "type": "Retail",
                    "path": "retail-starter-pack",
                    "features": [
                        "Sales and product analytics",
                        "Customer lifetime value",
                        "Inventory optimization insights",
                        "Cross-sell recommendations",
                        "Web analytics integration",
                        "Advanced segmentation"
                    ],
                    "workflows": [
                        "wf02_mapping.dig",
                        "wf03_validate.dig", 
                        "wf04_stage.dig",
                        "wf05_unify.dig",
                        "wf06_golden.dig",
                        "wf07_analytics.dig",
                        "wf08_create_refresh_master_segment.dig"
                    ]
                }
            ]
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch starter packs: {str(e)}")

@router.get("/pack-details/{pack_name}")
async def get_pack_details(pack_name: str):
    """Get detailed information about a specific starter pack"""
    try:
        # This would fetch from GitHub API
        # For demo, return mock detailed information
        if pack_name in ["qsr", "retail"]:
            return {
                "configuration": {
                    "src_params.yml": "# Source parameters configuration",
                    "email_ids.yml": "# Email notification configuration", 
                    "schema_map.yml": "# Schema mapping configuration"
                },
                "workflows": [
                    {"name": "wf02_mapping.dig", "description": "Data mapping workflow"},
                    {"name": "wf03_validate.dig", "description": "Data validation workflow"},
                    {"name": "wf04_stage.dig", "description": "Data staging workflow"}
                ]
            }
        else:
            raise HTTPException(status_code=404, detail="Starter pack not found")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch pack details: {str(e)}")

@router.get("/pack-files/{pack_name}")
async def get_pack_files(pack_name: str):
    """Get all files in a starter pack"""
    try:
        # This would fetch actual files from GitHub
        # For demo, return mock file structure
        return {
            "files": [
                {
                    "name": "config/src_params.yml",
                    "type": "yml",
                    "content": "# Source parameters\ndatabase: ${TD_DATABASE}\ntable_prefix: ${TABLE_PREFIX}"
                },
                {
                    "name": "wf02_mapping.dig", 
                    "type": "dig",
                    "content": "timezone: UTC\nschedule:\n  daily>: 02:00:00"
                }
            ]
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch pack files: {str(e)}")


class EnvironmentSecrets(BaseModel):
    prod: str = None
    qa: str = None
    dev: str = None

class TDCredentials(BaseModel):
    api_key: str
    region: str

class PackageCopyRequest(BaseModel):
    github_token: str
    organization: str = None
    repo_name: str
    package_name: str
    project_name: str
    session_id: str = None  # Optional session ID for progress tracking
    use_project_prefix: bool = True  # Whether to prefix files with project name
    create_ruleset: bool = True  # Whether to create repository ruleset (default True)
    environment_secrets: EnvironmentSecrets = EnvironmentSecrets()  # Environment secrets for TD_API_TOKEN
    td_credentials: TDCredentials = None  # TD credentials for region information

def get_github_tree(repo_owner: str, repo_name: str, path: str = "") -> List[Dict[str, Any]]:
    """Get the file tree from GitHub repository"""
    url = f"https://api.github.com/repos/{repo_owner}/{repo_name}/git/trees/main"
    if path:
        # Get tree for specific path
        url = f"https://api.github.com/repos/{repo_owner}/{repo_name}/contents/{path}"
    
    headers = {
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28'
    }
    
    response = requests.get(url, headers=headers)
    if not response.ok:
        raise HTTPException(status_code=response.status_code, 
                          detail=f"Failed to fetch repository tree: {response.text}")
    
    return response.json()

def get_package_files_from_github(package_name: str, github_token: str = None) -> List[Dict[str, Any]]:
    """Get all files from a package in the GitHub repository"""
    import requests
    import base64
    
    files = []
    
    # GitHub repository details
    repo_owner = "treasure-data"
    repo_name = "se-starter-pack"
    base_url = f"https://api.github.com/repos/{repo_owner}/{repo_name}"
    
    print(f"Starting to fetch files for package: {package_name}")
    print(f"GitHub repository: {repo_owner}/{repo_name}")
    print(f"Package directory: {package_name}")
    
    # Try GitHub first (may be private and require auth)
    
    def get_directory_contents(path: str = "") -> List[Dict[str, Any]]:
        """Recursively get all files from a directory in the GitHub repo"""
        url = f"{base_url}/contents/{path}" if path else f"{base_url}/contents"
        
        headers = {
            'Accept': 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2022-11-28'
        }
        
        # Add authentication if token is provided
        if github_token:
            headers['Authorization'] = f'Bearer {github_token}'
        
        try:
            response = requests.get(url, headers=headers, timeout=10)
            if not response.ok:
                print(f"Failed to fetch directory {path}: {response.status_code} - {response.text}")
                return []
            
            contents = response.json()
            directory_files = []
            
            for item in contents:
                if item['type'] == 'file':
                    # Get file content
                    file_response = requests.get(item['download_url'], timeout=10)
                    if file_response.ok:
                        try:
                            # Try to decode as text
                            content = file_response.text
                            encoding = 'utf-8'
                        except UnicodeDecodeError:
                            # If not text, encode as base64
                            content = base64.b64encode(file_response.content).decode('utf-8')
                            encoding = 'base64'
                        
                        # Remove package name prefix from path
                        relative_path = item['path']
                        if relative_path.startswith(f"{package_name}/"):
                            relative_path = relative_path[len(f"{package_name}/"):]
                        
                        directory_files.append({
                            'path': relative_path,
                            'content': content,
                            'encoding': encoding,
                            'sha': item['sha']
                        })
                        print(f"Added file: {item['path']}")
                    else:
                        print(f"Failed to download file {item['path']}: {file_response.status_code}")
                
                elif item['type'] == 'dir':
                    # Recursively get files from subdirectory
                    subdirectory_files = get_directory_contents(item['path'])
                    directory_files.extend(subdirectory_files)
            
            return directory_files
            
        except requests.exceptions.RequestException as e:
            print(f"Error fetching directory {path}: {e}")
            return []
    
    # Get all files from the package directory
    files = get_directory_contents(package_name)
    
    if not files:
        print(f"No files found for package {package_name} in GitHub repository")
        return []
    
    print(f"Total files collected: {len(files)}")
    return files


def create_repository_ruleset(token: str, owner: str, repo: str) -> Dict[str, Any]:
    """Create repository ruleset with branch naming rules"""
    url = f"https://api.github.com/repos/{owner}/{repo}/rulesets"
    
    headers = {
        'Authorization': f'Bearer {token}',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
        'Content-Type': 'application/json'
    }
    
    # Ruleset configuration based on your example
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
    print(f"Branch pattern: {ruleset_data['rules'][1]['parameters']['pattern']}")
    
    try:
        print(f"Making POST request to: {url}")
        print(f"Headers: {headers}")
        print(f"Payload: {ruleset_data}")
        
        response = requests.post(url, headers=headers, json=ruleset_data, timeout=15)
        
        print(f"Response status: {response.status_code}")
        print(f"Response headers: {dict(response.headers)}")
        print(f"Response body: {response.text[:500]}")
        
        if not response.ok:
            error_details = ""
            try:
                error_json = response.json()
                if 'message' in error_json:
                    error_details = f" - {error_json['message']}"
                if 'errors' in error_json:
                    error_details += f" - Errors: {error_json['errors']}"
                if 'documentation_url' in error_json:
                    error_details += f" - Docs: {error_json['documentation_url']}"
            except:
                error_details = f" - {response.text[:200]}"
            
            error_msg = f"Failed to create ruleset: {response.status_code}{error_details}"
            if response.status_code == 422:
                error_msg += " (Ruleset might already exist or validation failed)"
            elif response.status_code == 403:
                error_msg += " (Insufficient permissions for repository rulesets)"
            elif response.status_code == 404:
                error_msg += " (Repository not found or rulesets not enabled)"
            
            raise HTTPException(status_code=response.status_code, detail=error_msg)
        
        return response.json()
        
    except requests.exceptions.RequestException as e:
        error_msg = f"Network error creating ruleset: {str(e)}"
        print(f"Network error details: {e}")
        raise HTTPException(status_code=500, detail=error_msg)

def create_github_environment_secrets(token: str, owner: str, repo: str, environment_secrets: EnvironmentSecrets) -> Dict[str, Any]:
    """Create GitHub environment secrets for TD_API_TOKEN"""
    results = []
    
    for env_name, api_token in [("prod", environment_secrets.prod), ("qa", environment_secrets.qa), ("dev", environment_secrets.dev)]:
        if not api_token:
            continue
            
        print(f"Creating {env_name} environment and setting TD_API_TOKEN secret...")
        
        try:
            # Step 1: Create environment
            env_url = f"https://api.github.com/repos/{owner}/{repo}/environments/{env_name}"
            env_headers = {
                'Authorization': f'Bearer {token}',
                'Accept': 'application/vnd.github+json',
                'X-GitHub-Api-Version': '2022-11-28',
                'Content-Type': 'application/json'
            }
            
            env_data = {
                "wait_timer": 0,
                "reviewers": [],
                "deployment_branch_policy": None
            }
            
            env_response = requests.put(env_url, headers=env_headers, json=env_data, timeout=10)
            if env_response.ok:
                print(f"✅ Created {env_name} environment")
            else:
                print(f"⚠️ Environment {env_name} creation warning: {env_response.status_code} - {env_response.text}")
            
            # Step 2: Get public key for secret encryption
            public_key_url = f"https://api.github.com/repos/{owner}/{repo}/environments/{env_name}/secrets/public-key"
            public_key_response = requests.get(public_key_url, headers=env_headers, timeout=10)
            
            if not public_key_response.ok:
                raise Exception(f"Failed to get public key for {env_name}: {public_key_response.status_code}")
            
            public_key_data = public_key_response.json()
            
            # Step 3: Encrypt the secret (basic base64 encoding for now - should use proper encryption)
            import base64
            encrypted_value = base64.b64encode(api_token.encode('utf-8')).decode('utf-8')
            
            # Step 4: Set the secret
            secret_url = f"https://api.github.com/repos/{owner}/{repo}/environments/{env_name}/secrets/TD_API_TOKEN"
            secret_data = {
                "encrypted_value": encrypted_value,
                "key_id": public_key_data['key_id']
            }
            
            secret_response = requests.put(secret_url, headers=env_headers, json=secret_data, timeout=10)
            
            if secret_response.ok:
                print(f"✅ Set TD_API_TOKEN secret for {env_name} environment")
                results.append({
                    "environment": env_name,
                    "status": "success",
                    "message": f"TD_API_TOKEN secret set for {env_name}"
                })
            else:
                error_msg = f"Failed to set secret for {env_name}: {secret_response.status_code} - {secret_response.text}"
                print(f"❌ {error_msg}")
                results.append({
                    "environment": env_name,
                    "status": "error",
                    "message": error_msg
                })
                
        except Exception as e:
            error_msg = f"Error setting up {env_name} environment: {str(e)}"
            print(f"❌ {error_msg}")
            results.append({
                "environment": env_name,
                "status": "error",
                "message": error_msg
            })
    
    return {"results": results, "total_environments": len(results)}

def create_github_repository_variables(token: str, owner: str, repo: str, project_name: str, td_region: str) -> Dict[str, Any]:
    """Create GitHub repository variables for TD workflow configuration"""
    results = []
    
    # Determine API endpoint based on region
    td_api_endpoint = {
        'us01': 'https://api-workflow.treasuredata.com',
        'eu01': 'https://api-workflow.eu01.treasuredata.com',
        'ap01': 'https://api-workflow.ap01.treasuredata.com',
        'ap02': 'https://api-workflow.ap02.treasuredata.com',
        'ap03': 'https://api-workflow.ap03.treasuredata.com'
    }.get(td_region, 'https://api-workflow.treasuredata.com')
    
    # Variables to create
    variables = [
        {
            'name': 'TD_WF_API_ENDPOINT',
            'value': td_api_endpoint,
            'description': 'Treasure Data Workflow API endpoint'
        },
        {
            'name': 'TD_WF_PROJS',
            'value': project_name,
            'description': 'Treasure Data Workflow project name'
        }
    ]
    
    headers = {
        'Authorization': f'Bearer {token}',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
        'Content-Type': 'application/json'
    }
    
    for var in variables:
        print(f"Creating repository variable: {var['name']} = {var['value']}")
        
        try:
            # Create or update repository variable
            var_url = f"https://api.github.com/repos/{owner}/{repo}/actions/variables/{var['name']}"
            var_data = {
                'name': var['name'],
                'value': var['value']
            }
            
            # Try to update first (in case it exists)
            response = requests.patch(var_url, headers=headers, json={'value': var['value']}, timeout=10)
            
            if response.status_code == 404:
                # Variable doesn't exist, create it
                create_url = f"https://api.github.com/repos/{owner}/{repo}/actions/variables"
                response = requests.post(create_url, headers=headers, json=var_data, timeout=10)
            
            if response.ok or response.status_code == 201:
                print(f"✅ Set repository variable: {var['name']} = {var['value']}")
                results.append({
                    "variable": var['name'],
                    "value": var['value'],
                    "status": "success",
                    "message": f"Repository variable {var['name']} set successfully"
                })
            else:
                error_msg = f"Failed to set variable {var['name']}: {response.status_code} - {response.text}"
                print(f"❌ {error_msg}")
                results.append({
                    "variable": var['name'],
                    "value": var['value'],
                    "status": "error",
                    "message": error_msg
                })
                
        except Exception as e:
            error_msg = f"Error setting variable {var['name']}: {str(e)}"
            print(f"❌ {error_msg}")
            results.append({
                "variable": var['name'],
                "value": var['value'],
                "status": "error",
                "message": error_msg
            })
    
    return {"results": results, "total_variables": len(results)}

def create_github_file(token: str, owner: str, repo: str, file_path: str, content: str, 
                      message: str, encoding: str = 'utf-8') -> Dict[str, Any]:
    """Create a file in GitHub repository"""
    url = f"https://api.github.com/repos/{owner}/{repo}/contents/{file_path}"
    
    print(f"Creating GitHub file: {url}")
    print(f"Owner: {owner}, Repo: {repo}, File: {file_path}")
    
    # Encode content properly
    if encoding == 'base64':
        encoded_content = content  # Already base64 encoded
    else:
        encoded_content = base64.b64encode(content.encode('utf-8')).decode('utf-8')
    
    headers = {
        'Authorization': f'Bearer {token}',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28'
    }
    
    data = {
        'message': message,
        'content': encoded_content
    }
    
    print(f"Request headers: {headers}")
    print(f"Content length: {len(encoded_content)} characters")
    
    try:
        response = requests.put(url, headers=headers, json=data, timeout=15)
        
        if not response.ok:
            error_details = ""
            try:
                error_json = response.json()
                if 'message' in error_json:
                    error_details = f" - {error_json['message']}"
                if 'errors' in error_json:
                    error_details += f" - Errors: {error_json['errors']}"
            except:
                error_details = f" - {response.text[:200]}"
            
            error_msg = f"Failed to create file {file_path}: {response.status_code}{error_details}"
            if response.status_code == 429:  # Rate limit
                error_msg += " (Rate limit exceeded)"
            elif response.status_code == 422:  # Validation error
                error_msg += " (File might already exist or validation failed)"
            
            raise HTTPException(status_code=response.status_code, detail=error_msg)
        
        return response.json()
        
    except requests.exceptions.RequestException as e:
        error_msg = f"Network error creating file {file_path}: {str(e)}"
        raise HTTPException(status_code=500, detail=error_msg)

@router.post("/copy-package")
async def copy_package_to_github(request: PackageCopyRequest):
    """Copy package files to GitHub repository using git operations"""
    print(f"=== GIT-BASED COPY-PACKAGE API CALLED ===")
    print(f"Package: {request.package_name}")
    print(f"Repository: {request.repo_name}")
    print(f"Project: {request.project_name}")
    print(f"Organization: {request.organization}")
    print(f"Use project prefix: {request.use_project_prefix}")
    print(f"Create ruleset: {request.create_ruleset}")
    print(f"Environment secrets: {[env for env in ['prod', 'qa', 'dev'] if getattr(request.environment_secrets, env)]}")
    print(f"Session ID: {request.session_id}")
    
    # Generate session ID if not provided
    session_id = request.session_id or str(uuid.uuid4())
    print(f"Using session ID: {session_id}")
    
    # Initialize progress tracking
    copy_progress[session_id] = {
        'status': 'starting',
        'total_files': 0,
        'files_processed': 0,
        'files_created': 0,
        'files_failed': 0,
        'current_file': '',
        'errors': [],
        'started_at': None,
        'completed_at': None
    }
    
    try:
        import subprocess
        import tempfile
        import shutil
        import os
        
        copy_progress[session_id]['status'] = 'cloning_source'
        copy_progress[session_id]['started_at'] = __import__('datetime').datetime.now().isoformat()
        
        # Validate GitHub token first
        print(f"Validating GitHub token...")
        try:
            user_response = requests.get(
                "https://api.github.com/user",
                headers={
                    'Authorization': f'Bearer {request.github_token}',
                    'Accept': 'application/vnd.github+json'
                },
                timeout=10
            )
            if not user_response.ok:
                raise HTTPException(status_code=401, detail=f"Invalid GitHub token: {user_response.status_code}")
            
            user_info = user_response.json()
            owner = request.organization or user_info['login']
            print(f"✅ GitHub token validated for user: {user_info.get('login', 'unknown')}")
        except requests.exceptions.RequestException as e:
            raise HTTPException(status_code=500, detail=f"GitHub API connection failed: {str(e)}")
        
        # Create temporary directories
        with tempfile.TemporaryDirectory() as temp_dir:
            source_dir = f"{temp_dir}/source"
            dest_dir = f"{temp_dir}/destination"
            
            print(f"Using temp directory: {temp_dir}")
            
            # Step 1: Clone source repository
            copy_progress[session_id]['status'] = 'cloning_source'
            copy_progress[session_id]['current_file'] = 'Cloning source repository'
            print(f"Cloning source repository...")
            
            source_repo_url = f"https://{request.github_token}@github.com/treasure-data/se-starter-pack.git"
            result = subprocess.run([
                'git', 'clone', '--depth', '1', source_repo_url, source_dir
            ], capture_output=True, text=True, timeout=120)
            
            if result.returncode != 0:
                error_msg = f"Failed to clone source repository: {result.stderr}"
                print(f"❌ {error_msg}")
                raise HTTPException(status_code=500, detail=error_msg)
            
            print(f"✅ Source repository cloned successfully")
            
            # Step 2: Clone or initialize destination repository
            copy_progress[session_id]['status'] = 'preparing_destination'
            copy_progress[session_id]['current_file'] = 'Preparing destination repository'
            print(f"Preparing destination repository...")
            
            dest_repo_url = f"https://{request.github_token}@github.com/{owner}/{request.repo_name}.git"
            
            # Try to clone destination repo (might be empty)
            clone_result = subprocess.run([
                'git', 'clone', dest_repo_url, dest_dir
            ], capture_output=True, text=True, timeout=60)
            
            if clone_result.returncode != 0:
                # If clone fails, create a new repo locally
                print(f"Destination repo doesn't exist or is empty, initializing...")
                subprocess.run(['git', 'init', dest_dir], check=True)
                subprocess.run(['git', 'remote', 'add', 'origin', dest_repo_url], cwd=dest_dir, check=True)
                
                # Create initial commit if needed
                with open(f"{dest_dir}/README.md", 'w') as f:
                    f.write(f"# {request.repo_name}\n\nValue Accelerator deployment\n")
                subprocess.run(['git', 'add', 'README.md'], cwd=dest_dir, check=True)
                subprocess.run(['git', 'config', 'user.name', 'TD Value Accelerator'], cwd=dest_dir, check=True)
                subprocess.run(['git', 'config', 'user.email', 'noreply@treasuredata.com'], cwd=dest_dir, check=True)
                subprocess.run(['git', 'commit', '-m', 'Initial commit'], cwd=dest_dir, check=True)
            
            print(f"✅ Destination repository prepared")
            
            # Step 3: Copy package files
            copy_progress[session_id]['status'] = 'copying_files'
            copy_progress[session_id]['current_file'] = f'Copying {request.package_name} files'
            print(f"Copying {request.package_name} files...")
            
            source_package_path = f"{source_dir}/{request.package_name}"
            if not os.path.exists(source_package_path):
                raise HTTPException(status_code=404, detail=f"Package {request.package_name} not found in source repository")
            
            # Always put project files in a project folder
            dest_project_path = f"{dest_dir}/{request.project_name}"
            os.makedirs(dest_project_path, exist_ok=True)
            
            # Copy all package files to project folder
            for item in os.listdir(source_package_path):
                s = os.path.join(source_package_path, item)
                d = os.path.join(dest_project_path, item)
                if os.path.isdir(s):
                    shutil.copytree(s, d, dirs_exist_ok=True)
                else:
                    shutil.copy2(s, d)
            
            print(f"✅ Copied package files to {request.project_name} folder")
            
            # Step 3b: Copy GitHub Actions workflows to root
            copy_progress[session_id]['current_file'] = 'Copying GitHub Actions workflows'
            print(f"Looking for GitHub Actions workflows...")
            
            # Check for .github directory in the source repo root
            source_github_dir = f"{source_dir}/.github"
            if os.path.exists(source_github_dir):
                dest_github_dir = f"{dest_dir}/.github"
                shutil.copytree(source_github_dir, dest_github_dir, dirs_exist_ok=True)
                print(f"✅ Copied .github directory to repository root")
            else:
                print(f"ℹ️ No .github directory found in source repository")
            
            # Count files for progress tracking (exclude .git)
            file_count = 0
            for root, dirs, files in os.walk(dest_dir):
                if '.git' in root:
                    continue
                file_count += len(files)
            
            copy_progress[session_id]['total_files'] = file_count
            copy_progress[session_id]['files_created'] = file_count
            
            print(f"✅ Total files in repository: {file_count}")
            
            # Step 4: Commit and push changes
            copy_progress[session_id]['status'] = 'committing'
            copy_progress[session_id]['current_file'] = 'Committing changes'
            print(f"Committing changes...")
            
            subprocess.run(['git', 'add', '.'], cwd=dest_dir, check=True)
            
            # Check if there are changes to commit
            status_result = subprocess.run(['git', 'status', '--porcelain'], 
                                         cwd=dest_dir, capture_output=True, text=True, check=True)
            
            if status_result.stdout.strip():
                commit_message = f"Deploy {request.package_name} to {request.project_name}\n\n" \
                               f"- Package: {request.package_name}\n" \
                               f"- Project: {request.project_name}\n" \
                               f"- Files: {file_count}\n\n" \
                               f"🤖 Generated with TD Value Accelerator"
                subprocess.run(['git', 'commit', '-m', commit_message], cwd=dest_dir, check=True)
                
                copy_progress[session_id]['status'] = 'pushing'
                copy_progress[session_id]['current_file'] = 'Pushing to GitHub'
                print(f"Pushing to GitHub...")
                
                push_result = subprocess.run(['git', 'push', 'origin', 'main'], 
                                           cwd=dest_dir, capture_output=True, text=True, timeout=120)
                
                if push_result.returncode != 0:
                    # Try 'master' branch if 'main' fails
                    push_result = subprocess.run(['git', 'push', 'origin', 'master'], 
                                               cwd=dest_dir, capture_output=True, text=True, timeout=120)
                
                if push_result.returncode != 0:
                    error_msg = f"Failed to push to GitHub: {push_result.stderr}"
                    print(f"❌ {error_msg}")
                    raise HTTPException(status_code=500, detail=error_msg)
                
                print(f"✅ Successfully pushed changes to GitHub")
            else:
                print(f"ℹ️ No changes to commit")
        
        # Step 5: Create repository ruleset (if requested)
        if request.create_ruleset:
            copy_progress[session_id]['status'] = 'creating_ruleset'
            copy_progress[session_id]['current_file'] = 'Setting up repository ruleset'
            print(f"Creating repository ruleset...")
            
            try:
                print(f"Attempting to create ruleset for {owner}/{request.repo_name}")
                print(f"Token length: {len(request.github_token)} characters")
                ruleset_result = create_repository_ruleset(
                    token=request.github_token,
                    owner=owner,
                    repo=request.repo_name
                )
                print(f"✅ Repository ruleset created: {ruleset_result.get('name', 'Enforce Branch Names')}")
                print(f"Ruleset ID: {ruleset_result.get('id', 'unknown')}")
            except Exception as ruleset_error:
                print(f"⚠️ Warning: Failed to create ruleset: {str(ruleset_error)}")
                print(f"Error type: {type(ruleset_error).__name__}")
                import traceback
                print(f"Full traceback: {traceback.format_exc()}")
                # Don't fail the entire deployment if ruleset creation fails
        else:
            print(f"ℹ️ Skipping ruleset creation (create_ruleset=False)")
        
        # Step 6: Create environment secrets (if provided)
        env_secrets_list = [env for env in ['prod', 'qa', 'dev'] if getattr(request.environment_secrets, env)]
        if env_secrets_list:
            copy_progress[session_id]['status'] = 'creating_secrets'
            copy_progress[session_id]['current_file'] = 'Setting up environment secrets'
            print(f"Creating environment secrets for: {', '.join(env_secrets_list)}")
            
            try:
                secrets_result = create_github_environment_secrets(
                    token=request.github_token,
                    owner=owner,
                    repo=request.repo_name,
                    environment_secrets=request.environment_secrets
                )
                successful_envs = [result['environment'] for result in secrets_result['results'] if result['status'] == 'success']
                failed_envs = [result['environment'] for result in secrets_result['results'] if result['status'] == 'error']
                
                if successful_envs:
                    print(f"✅ Environment secrets created for: {', '.join(successful_envs)}")
                if failed_envs:
                    print(f"⚠️ Failed to create secrets for: {', '.join(failed_envs)}")
                    
            except Exception as secrets_error:
                print(f"⚠️ Warning: Failed to create environment secrets: {str(secrets_error)}")
                import traceback
                print(f"Full traceback: {traceback.format_exc()}")
                # Don't fail the entire deployment if secrets creation fails
        else:
            print(f"ℹ️ No environment secrets to create")
        
        # Step 7: Create repository variables
        copy_progress[session_id]['status'] = 'creating_variables'
        copy_progress[session_id]['current_file'] = 'Setting up repository variables'
        print(f"Creating repository variables for TD Workflow...")
        
        try:
            variables_result = create_github_repository_variables(
                token=request.github_token,
                owner=owner,
                repo=request.repo_name,
                project_name=request.project_name,
                td_region=request.td_credentials.region if request.td_credentials else 'us01'
            )
            successful_vars = [result['variable'] for result in variables_result['results'] if result['status'] == 'success']
            failed_vars = [result['variable'] for result in variables_result['results'] if result['status'] == 'error']
            
            if successful_vars:
                print(f"✅ Repository variables created: {', '.join(successful_vars)}")
            if failed_vars:
                print(f"⚠️ Failed to create variables: {', '.join(failed_vars)}")
                
        except Exception as variables_error:
            print(f"⚠️ Warning: Failed to create repository variables: {str(variables_error)}")
            import traceback
            print(f"Full traceback: {traceback.format_exc()}")
            # Don't fail the entire deployment if variables creation fails
        
        # Update final progress
        copy_progress[session_id]['status'] = 'completed'
        copy_progress[session_id]['completed_at'] = __import__('datetime').datetime.now().isoformat()
        
        return {
            'success': True,
            'message': f'Successfully deployed {request.package_name} using git operations',
            'total_files': copy_progress[session_id]['total_files'],
            'success_count': copy_progress[session_id]['files_created'],
            'failed_count': 0,
            'session_id': session_id,
            'method': 'git_operations'
        }
        
    except Exception as e:
        copy_progress[session_id]['status'] = 'error'
        copy_progress[session_id]['errors'].append(f"Fatal error: {str(e)}")
        copy_progress[session_id]['completed_at'] = __import__('datetime').datetime.now().isoformat()
        raise HTTPException(status_code=500, detail=f"Error copying package: {str(e)}")

@router.get("/packages")
async def list_available_packages():
    """List available starter packages from local repository"""
    try:
        import os
        
        # Get the absolute path to the repository root
        # Current file is at: /path/to/se-starter-pack/td-value-accelerator/server/routers/github.py
        # We need to go up 3 levels to get to se-starter-pack root
        current_dir = os.path.dirname(os.path.abspath(__file__))
        repo_root = os.path.dirname(os.path.dirname(os.path.dirname(current_dir)))
        
        print(f"Searching for packages in: {repo_root}")
        
        packages = []
        
        # Look for directories ending with '-starter-pack'
        for item in os.listdir(repo_root):
            item_path = os.path.join(repo_root, item)
            if (os.path.isdir(item_path) and 
                item.endswith('-starter-pack')):
                
                print(f"Found package: {item}")
                packages.append({
                    'id': item,
                    'name': item.replace('-', ' ').title(),
                    'description': f"Starter pack for {item.replace('-starter-pack', '').replace('-', ' ').title()}"
                })
        
        print(f"Total packages found: {len(packages)}")
        return {'packages': packages}
        
    except Exception as e:
        print(f"Error listing packages: {e}")
        raise HTTPException(status_code=500, detail=f"Error listing packages: {str(e)}")

@router.get("/copy-progress/{session_id}")
async def get_copy_progress(session_id: str):
    """Get the progress of a file copy operation"""
    if session_id not in copy_progress:
        raise HTTPException(status_code=404, detail="Session not found")
    
    return copy_progress[session_id]