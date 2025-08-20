from pydantic import BaseModel
from typing import List, Dict, Any, Optional
from enum import Enum

class DeploymentStatus(str, Enum):
    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"

class TDCredentials(BaseModel):
    apiKey: str
    region: str

class StarterPack(BaseModel):
    id: str
    name: str
    description: str
    type: str
    features: List[str]
    workflows: List[str]

class DeploymentConfig(BaseModel):
    starterPack: StarterPack
    parameters: Dict[str, Any]
    customTableNames: Optional[Dict[str, str]] = {}

class DeploymentStatusResponse(BaseModel):
    id: str
    status: DeploymentStatus
    progress: int
    logs: List[str]
    error: Optional[str] = None
    startTime: str
    endTime: Optional[str] = None