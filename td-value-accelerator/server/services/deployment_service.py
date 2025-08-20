import asyncio
from typing import Dict, Any, List
from models.deployment import DeploymentConfig, DeploymentStatus, TDCredentials
from services.td_service import TDMCPService
from services.github_service import GitHubService
import uuid
from datetime import datetime

class DeploymentService:
    """Service to handle deployment orchestration"""
    
    def __init__(self):
        self.td_service = TDMCPService()
        self.github_service = GitHubService()
    
    async def prepare_deployment(self, config: DeploymentConfig) -> Dict[str, Any]:
        """Prepare deployment by fetching required files and validating configuration"""
        try:
            # Get all starter pack files from local filesystem
            workflow_files = await self.github_service.get_workflow_files(config.starterPack.id)
            config_files = await self.github_service.get_config_files(config.starterPack.id)
            all_files = await self.github_service.get_all_files(config.starterPack.id)
            
            # Process configuration templates
            processed_configs = self._process_config_templates(config_files, config.parameters)
            
            return {
                "status": "prepared",
                "workflow_files": workflow_files,
                "config_files": processed_configs,
                "all_files": all_files,
                "total_files": len(all_files),
                "estimated_duration": len(workflow_files) * 3  # minutes
            }
            
        except Exception as e:
            return {
                "status": "error",
                "message": f"Failed to prepare deployment: {str(e)}"
            }
    
    async def execute_deployment(self, config: DeploymentConfig, deployment_id: str) -> Dict[str, Any]:
        """Execute the full deployment process"""
        try:
            # Get prepared deployment data
            preparation = await self.prepare_deployment(config)
            if preparation["status"] == "error":
                return preparation
            
            # Execute workflows in sequence
            workflow_results = []
            for workflow in preparation["workflow_files"]:
                result = await self._execute_single_workflow(
                    workflow, 
                    config, 
                    deployment_id
                )
                workflow_results.append(result)
                
                if result["status"] == "error":
                    return {
                        "status": "error",
                        "message": f"Workflow {workflow['name']} failed: {result['message']}"
                    }
                
                # Simulate delay between workflows
                await asyncio.sleep(1)
            
            return {
                "status": "completed",
                "workflows_executed": len(workflow_results),
                "results": workflow_results
            }
            
        except Exception as e:
            return {
                "status": "error",
                "message": f"Deployment execution failed: {str(e)}"
            }
    
    async def _execute_single_workflow(self, workflow: Dict[str, Any], config: DeploymentConfig, deployment_id: str) -> Dict[str, Any]:
        """Execute a single workflow"""
        try:
            # Create TD credentials from config (this would be passed properly in real implementation)
            credentials = TDCredentials(
                apiKey="demo_key",  # This would come from secure storage
                region=config.parameters.get("region", "us-east-1"),
                database=config.parameters.get("database", "default")
            )
            
            # Process workflow content with parameters
            processed_content = self._process_workflow_template(
                workflow["content"], 
                config.parameters
            )
            
            # Execute via TD MCP service
            result = await self.td_service.execute_workflow(
                credentials,
                processed_content,
                workflow["name"]
            )
            
            return {
                "workflow": workflow["name"],
                "status": result["status"],
                "message": result.get("message", ""),
                "workflow_id": result.get("workflow_id")
            }
            
        except Exception as e:
            return {
                "workflow": workflow["name"],
                "status": "error", 
                "message": str(e)
            }
    
    def _process_config_templates(self, config_files: Dict[str, str], parameters: Dict[str, Any]) -> Dict[str, str]:
        """Process configuration file templates with parameters"""
        processed = {}
        
        for filename, content in config_files.items():
            # Replace template variables
            processed_content = content
            for key, value in parameters.items():
                placeholder = f"${{{key.upper()}}}"
                if isinstance(value, list):
                    # Handle list values (like email_ids)
                    if "email" in key.lower():
                        value_str = "\n".join([f"  - {email}" for email in value])
                    else:
                        value_str = str(value)
                else:
                    value_str = str(value)
                
                processed_content = processed_content.replace(placeholder, value_str)
            
            processed[filename] = processed_content
        
        return processed
    
    def _process_workflow_template(self, workflow_content: str, parameters: Dict[str, Any]) -> str:
        """Process workflow template with parameters"""
        processed_content = workflow_content
        
        # Replace common template variables
        replacements = {
            "${TD_DATABASE}": parameters.get("database", "default"),
            "${TABLE_PREFIX}": parameters.get("table_prefix", ""),
            "${ENVIRONMENT}": parameters.get("environment", "production")
        }
        
        for placeholder, value in replacements.items():
            processed_content = processed_content.replace(placeholder, str(value))
        
        return processed_content