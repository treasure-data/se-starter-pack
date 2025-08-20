from fastapi import APIRouter, HTTPException, WebSocket, WebSocketDisconnect
from models.deployment import DeploymentConfig, DeploymentStatusResponse, DeploymentStatus
import uuid
import asyncio
from datetime import datetime
from typing import Dict
import json

router = APIRouter()

# In-memory storage for demo (use a database in production)
deployments: Dict[str, DeploymentStatusResponse] = {}
active_connections: Dict[str, WebSocket] = {}

@router.post("/configure")
async def configure_deployment(config: DeploymentConfig):
    """Configure deployment parameters"""
    try:
        # Validate configuration
        if not config.starterPack.id:
            raise HTTPException(status_code=400, detail="Starter pack not specified")
        
        # Return configuration summary
        return {
            "status": "configured",
            "pack": config.starterPack.name,
            "parameters": config.parameters,
            "estimated_duration": "15-30 minutes"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Configuration failed: {str(e)}")

@router.post("/deploy")
async def start_deployment(config: DeploymentConfig):
    """Start the deployment process"""
    try:
        deployment_id = str(uuid.uuid4())
        
        # Create deployment status
        deployment = DeploymentStatusResponse(
            id=deployment_id,
            status=DeploymentStatus.PENDING,
            progress=0,
            logs=[],
            startTime=datetime.now().isoformat()
        )
        
        deployments[deployment_id] = deployment
        
        # Start async deployment process
        asyncio.create_task(run_deployment(deployment_id, config))
        
        return {"deployment_id": deployment_id, "status": "started"}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Deployment failed to start: {str(e)}")

@router.get("/status/{deployment_id}")
async def get_deployment_status(deployment_id: str):
    """Get deployment status"""
    if deployment_id not in deployments:
        raise HTTPException(status_code=404, detail="Deployment not found")
    
    return deployments[deployment_id]

@router.websocket("/logs/{deployment_id}")
async def deployment_logs(websocket: WebSocket, deployment_id: str):
    """WebSocket endpoint for real-time deployment logs"""
    await websocket.accept()
    active_connections[deployment_id] = websocket
    
    try:
        while True:
            # Keep connection alive
            await asyncio.sleep(1)
            
            # Send periodic updates if deployment exists
            if deployment_id in deployments:
                deployment = deployments[deployment_id]
                await websocket.send_text(json.dumps({
                    "type": "status",
                    "status": deployment.dict()
                }))
                
                if deployment.status in [DeploymentStatus.COMPLETED, DeploymentStatus.FAILED]:
                    break
            else:
                break
                
    except WebSocketDisconnect:
        if deployment_id in active_connections:
            del active_connections[deployment_id]

async def run_deployment(deployment_id: str, config: DeploymentConfig):
    """Simulate deployment process"""
    deployment = deployments[deployment_id]
    
    try:
        # Update to running
        deployment.status = DeploymentStatus.RUNNING
        deployment.progress = 10
        deployment.logs.append("Starting deployment process...")
        
        await send_log(deployment_id, "Initializing deployment environment...")
        await asyncio.sleep(2)
        
        # Simulate workflow steps
        workflows = config.starterPack.workflows
        step_progress = 80 // len(workflows)
        
        for i, workflow in enumerate(workflows):
            deployment.progress = 10 + (i + 1) * step_progress
            log_msg = f"Executing workflow: {workflow}"
            deployment.logs.append(log_msg)
            await send_log(deployment_id, log_msg)
            await asyncio.sleep(3)  # Simulate work
        
        # Complete deployment
        deployment.status = DeploymentStatus.COMPLETED
        deployment.progress = 100
        deployment.endTime = datetime.now().isoformat()
        deployment.logs.append("Deployment completed successfully!")
        
        await send_log(deployment_id, "Deployment completed successfully!")
        
    except Exception as e:
        deployment.status = DeploymentStatus.FAILED
        deployment.error = str(e)
        deployment.endTime = datetime.now().isoformat()
        deployment.logs.append(f"Deployment failed: {str(e)}")
        
        await send_log(deployment_id, f"Deployment failed: {str(e)}")

async def send_log(deployment_id: str, message: str):
    """Send log message via WebSocket"""
    if deployment_id in active_connections:
        try:
            await active_connections[deployment_id].send_text(json.dumps({
                "type": "log",
                "message": message
            }))
        except:
            # Connection closed
            if deployment_id in active_connections:
                del active_connections[deployment_id]