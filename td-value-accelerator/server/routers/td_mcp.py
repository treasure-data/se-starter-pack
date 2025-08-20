from fastapi import APIRouter, HTTPException
from models.deployment import TDCredentials
import requests
import json

router = APIRouter()

@router.post("/test-connection")
async def test_td_connection(credentials: TDCredentials):
    """Test connection to Treasure Data via MCP server"""
    
    # Basic validation - just check if fields exist
    if not credentials.apiKey or not credentials.region:
        missing = []
        if not credentials.apiKey:
            missing.append("API Key")
        if not credentials.region:
            missing.append("Region")
        raise HTTPException(
            status_code=400, 
            detail=f"Missing required fields: {', '.join(missing)}"
        )
    
    try:
        # First try MCP server
        mcp_url = "http://localhost:8001"
        
        try:
            # Try to call list_databases to verify connection
            response = requests.post(
                f"{mcp_url}/mcp/v1/resources",
                json={
                    "method": "list_databases",
                    "params": {}
                },
                headers={
                    "X-TD-API-KEY": credentials.apiKey,
                    "X-TD-REGION": credentials.region
                },
                timeout=10
            )
            
            if response.status_code == 200:
                data = response.json()
                db_count = len(data.get('databases', []))
                return {
                    "status": "success", 
                    "message": f"Successfully connected to Treasure Data ({credentials.region})",
                    "details": f"Found {db_count} databases accessible with your credentials"
                }
            elif response.status_code == 401:
                raise HTTPException(
                    status_code=401, 
                    detail="Authentication failed. Please verify your API key is correct and has not expired."
                )
            elif response.status_code == 403:
                raise HTTPException(
                    status_code=403, 
                    detail="Access denied. Your API key may not have sufficient permissions to access databases."
                )
            elif response.status_code == 404:
                raise HTTPException(
                    status_code=404, 
                    detail=f"Region '{credentials.region}' not found. Please verify the region is correct."
                )
            else:
                error_msg = _extract_error_message(response)
                raise HTTPException(
                    status_code=response.status_code, 
                    detail=f"Treasure Data API returned error: {error_msg}"
                )
                    
        except requests.ConnectionError:
            # MCP server not available, try direct TD API call
            return await _test_direct_td_api(credentials)
        except requests.Timeout:
            raise HTTPException(
                status_code=504, 
                detail="Connection to Treasure Data timed out. Please check your network connection and try again."
            )
            
    except HTTPException:
        # Re-raise HTTPExceptions from nested functions
        raise
    except requests.RequestException as e:
        raise HTTPException(
            status_code=500, 
            detail=f"Network error while testing connection: {str(e)}"
        )
    except Exception as e:
        raise HTTPException(
            status_code=500, 
            detail=f"Unexpected error during connection test: {str(e)}"
        )

async def _test_direct_td_api(credentials: TDCredentials):
    """Test connection directly to Treasure Data API when MCP server is unavailable"""
    try:
        # Get the correct API endpoint based on region
        api_base = f"https://api.treasuredata.com" if credentials.region == "us01" else f"https://api.{credentials.region}.treasuredata.com"
        
        # Test with a simple API call to list databases
        response = requests.get(
            f"{api_base}/v3/database/list",
            headers={
                "Authorization": f"TD1 {credentials.apiKey}",
                "User-Agent": "TD-Value-Accelerator/1.0"
            },
            timeout=15
        )
        
        if response.status_code == 200:
            data = response.json()
            db_count = len(data.get('databases', []))
            return {
                "status": "success",
                "message": f"Successfully connected to Treasure Data ({credentials.region})",
                "details": f"Found {db_count} databases accessible with your credentials (direct API connection)"
            }
        elif response.status_code == 401:
            error_msg = _extract_error_message(response)
            raise HTTPException(
                status_code=401,
                detail=f"Authentication failed: {error_msg}. Please verify your API key is correct and has not expired."
            )
        elif response.status_code == 403:
            error_msg = _extract_error_message(response)
            raise HTTPException(
                status_code=403,
                detail=f"Access denied: {error_msg}. Your API key may not have sufficient permissions to access databases."
            )
        else:
            error_msg = _extract_error_message(response)
            raise HTTPException(
                status_code=response.status_code,
                detail=f"Treasure Data API returned error ({response.status_code}): {error_msg}"
            )
            
    except HTTPException:
        # Re-raise HTTPExceptions as-is
        raise
    except requests.RequestException as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to connect to Treasure Data API: {str(e)}"
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Unexpected error connecting to Treasure Data: {str(e)}"
        )


def _extract_error_message(response) -> str:
    """Extract meaningful error message from API response"""
    try:
        error_data = response.json()
        # Try different common error message fields
        for field in ['detail', 'message', 'error', 'error_message', 'description']:
            if field in error_data and error_data[field]:
                return str(error_data[field])
        
        # If no specific error message, return the entire response for debugging
        if error_data:
            return str(error_data)
        else:
            return f"HTTP {response.status_code} - {response.reason or 'Unknown error'}"
    except Exception:
        # If we can't parse JSON, try to get text content
        try:
            text_content = response.text.strip()
            if text_content:
                return f"HTTP {response.status_code}: {text_content[:200]}"
            else:
                return f"HTTP {response.status_code} - {response.reason or 'Unknown error'}"
        except Exception:
            return f"HTTP {response.status_code} - {response.reason or 'Unknown error'}"

def _get_user_friendly_error(error_str: str) -> str:
    """Convert technical error messages to user-friendly ones"""
    error_lower = error_str.lower()
    
    if 'connection refused' in error_lower:
        return "Connection refused - service may be down or blocked by firewall"
    elif 'timeout' in error_lower:
        return "Request timed out - please check your network connection"
    elif 'ssl' in error_lower or 'certificate' in error_lower:
        return "SSL/Certificate error - please check your network security settings"
    elif 'dns' in error_lower or 'name resolution' in error_lower:
        return "DNS resolution failed - please check your network connection"
    elif 'permission denied' in error_lower:
        return "Permission denied - please check your credentials and access rights"
    else:
        return error_str

@router.get("/databases")
async def list_databases():
    """List available databases"""
    try:
        # This would call the TD MCP server
        # For demo, return mock data
        return {
            "databases": [
                {"name": "production", "description": "Production database"},
                {"name": "staging", "description": "Staging database"},
                {"name": "development", "description": "Development database"}
            ]
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to list databases: {str(e)}")

@router.get("/tables/{database}")
async def list_tables(database: str):
    """List tables in a database"""
    try:
        # This would call the TD MCP server
        # For demo, return mock data
        return {
            "tables": [
                {"name": "customers", "rows": 1000000},
                {"name": "orders", "rows": 500000},
                {"name": "products", "rows": 10000}
            ]
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to list tables: {str(e)}")