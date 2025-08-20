from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
import sys
import os

# Add the server directory to Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from routers import td_mcp, github, deployment

app = FastAPI(
    title="TD Value Accelerator API",
    description="Backend API for TD Value Accelerator deployment tool",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:3001", "http://localhost:3002", "http://127.0.0.1:3000", "http://127.0.0.1:3001"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(td_mcp.router, prefix="/api/td", tags=["TD MCP"])
app.include_router(github.router, prefix="/api/github", tags=["GitHub"])
app.include_router(deployment.router, prefix="/api/deployment", tags=["Deployment"])

@app.get("/")
async def root():
    return {"message": "TD Value Accelerator API", "version": "1.0.0"}

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)