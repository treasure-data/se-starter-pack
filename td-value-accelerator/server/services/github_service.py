import requests
from typing import Dict, Any, List
import os
import glob
from pathlib import Path

class GitHubService:
    """Service to interact with GitHub repository"""
    
    def __init__(self):
        self.repo_owner = "treasure-data"
        self.repo_name = "se-starter-pack"
        self.base_url = f"https://api.github.com/repos/{self.repo_owner}/{self.repo_name}"
        self.raw_base_url = f"https://raw.githubusercontent.com/{self.repo_owner}/{self.repo_name}/main"
        # Path to the local starter pack directory
        self.local_repo_path = Path(__file__).parent.parent.parent.parent
    
    async def get_starter_pack_info(self, pack_name: str) -> Dict[str, Any]:
        """Get starter pack information from GitHub"""
        try:
            # For demo, return predefined information
            packs = {
                "qsr": {
                    "id": "qsr",
                    "name": "QSR Starter Pack",
                    "description": "Quick Service Restaurant analytics and customer journey tracking",
                    "type": "QSR",
                    "path": "qsr-starter-pack"
                },
                "retail": {
                    "id": "retail", 
                    "name": "Retail Starter Pack",
                    "description": "Comprehensive retail analytics with customer insights and product performance",
                    "type": "Retail",
                    "path": "retail-starter-pack"
                }
            }
            
            return packs.get(pack_name, {})
            
        except Exception as e:
            print(f"Error fetching starter pack info: {e}")
            return {}
    
    async def get_workflow_files(self, pack_name: str) -> List[Dict[str, Any]]:
        """Get workflow files for a starter pack"""
        try:
            workflows = []
            starter_pack_path = self.local_repo_path / f"{pack_name}-starter-pack"
            
            if not starter_pack_path.exists():
                print(f"Starter pack directory not found: {starter_pack_path}")
                return []
            
            # Find all .dig workflow files in the starter pack directory
            workflow_files = list(starter_pack_path.glob("wf*.dig"))
            workflow_files.sort()  # Sort to ensure consistent order
            
            for workflow_file in workflow_files:
                try:
                    with open(workflow_file, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    workflows.append({
                        "name": workflow_file.name,
                        "path": f"{pack_name}-starter-pack/{workflow_file.name}",
                        "content": content
                    })
                except Exception as e:
                    print(f"Error reading workflow file {workflow_file}: {e}")
                    continue
            
            return workflows
            
        except Exception as e:
            print(f"Error fetching workflow files: {e}")
            return []
    
    async def get_config_files(self, pack_name: str) -> Dict[str, str]:
        """Get configuration files for a starter pack"""
        try:
            configs = {}
            starter_pack_path = self.local_repo_path / f"{pack_name}-starter-pack"
            
            if not starter_pack_path.exists():
                print(f"Starter pack directory not found: {starter_pack_path}")
                return {}
            
            # Read config files from the config directory
            config_path = starter_pack_path / "config"
            if config_path.exists():
                for config_file in config_path.glob("*.yml"):
                    try:
                        with open(config_file, 'r', encoding='utf-8') as f:
                            configs[config_file.name] = f.read()
                    except Exception as e:
                        print(f"Error reading config file {config_file}: {e}")
                        continue
            
            return configs
            
        except Exception as e:
            print(f"Error fetching config files: {e}")
            return {}
    
    async def get_all_files(self, pack_name: str) -> Dict[str, Any]:
        """Get all files and directories for a starter pack"""
        try:
            all_files = {}
            starter_pack_path = self.local_repo_path / f"{pack_name}-starter-pack"
            
            if not starter_pack_path.exists():
                print(f"Starter pack directory not found: {starter_pack_path}")
                return {}
            
            # Recursively get all files
            for file_path in starter_pack_path.rglob("*"):
                if file_path.is_file():
                    # Get relative path from starter pack root
                    relative_path = file_path.relative_to(starter_pack_path)
                    
                    try:
                        # Try to read as text first
                        with open(file_path, 'r', encoding='utf-8') as f:
                            content = f.read()
                        file_type = "text"
                    except UnicodeDecodeError:
                        # If not text, read as binary
                        with open(file_path, 'rb') as f:
                            content = f.read()
                        file_type = "binary"
                    except Exception as e:
                        print(f"Error reading file {file_path}: {e}")
                        continue
                    
                    all_files[str(relative_path)] = {
                        "content": content,
                        "type": file_type,
                        "path": str(relative_path)
                    }
            
            return all_files
            
        except Exception as e:
            print(f"Error fetching all files: {e}")
            return {}