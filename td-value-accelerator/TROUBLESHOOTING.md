# Troubleshooting Guide

## Fixed Issues ✅

### 1. Node.js Compatibility Error
**Error**: `TypeError: crypto.hash is not a function`

**Solution**: Downgraded Vite to version 5.4.0 for Node.js 18 compatibility
```bash
npm install vite@5.4.0 @vitejs/plugin-react@4.3.0 --save-dev
```

### 2. Python Package Installation Error
**Error**: `pip._vendor.packaging.version.InvalidVersion: Invalid version: '4.0.0-unsupported'`

**Solution**: Created virtual environment setup script
```bash
npm run server:install  # Uses setup-backend.sh
```

### 3. FastAPI Server Warning
**Error**: `WARNING: You must pass the application as an import string to enable 'reload' or 'workers'.`

**Solution**: Updated main.py to use string import
```python
uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
```

## Current Setup Status ✅

- **Frontend**: Vite 5.4.0 running on port 3000
- **Backend**: FastAPI with uvicorn running on port 8000  
- **Virtual Environment**: Isolated Python dependencies
- **Development Scripts**: Multiple startup options

## Startup Options

### Option 1: Startup Script (Recommended)
```bash
npm run dev:full
```
- Uses `start-dev.sh`
- Better process management
- Clear status messages

### Option 2: Concurrently
```bash
npm run dev:concurrent
```
- Color-coded output
- Automatic cleanup on exit

### Option 3: Manual
```bash
# Terminal 1
npm run dev

# Terminal 2  
npm run server
```

## Validation

### Test Your Setup
```bash
source venv/bin/activate && python test-setup.py
```

### Expected Output
```
✅ All required packages imported successfully
✅ FastAPI app created successfully
🎉 All tests passed! The setup is working correctly.
```

## Port Information

- **Frontend**: http://localhost:3000
- **Backend**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs

## Common Issues

### Port Already in Use
```bash
# Kill processes on ports
lsof -ti:3000 | xargs kill -9
lsof -ti:8000 | xargs kill -9
```

### Virtual Environment Issues
```bash
# Recreate virtual environment
rm -rf venv
python -m venv venv
source venv/bin/activate
cd server && pip install -r requirements.txt
```

### Node.js Version Issues
- Minimum required: Node.js 18+
- If using Node.js 16 or below, upgrade to Node.js 18+

### Python Version Issues
- Minimum required: Python 3.8+
- Virtual environment isolates from system conflicts

## Development URLs

After starting the servers, access:

- **Application**: http://localhost:3000
- **Configuration**: http://localhost:3000/configuration
- **Selection**: http://localhost:3000/selection  
- **Deployment**: http://localhost:3000/deployment
- **API Docs**: http://localhost:8000/docs
- **API Health**: http://localhost:8000/

## Need More Help?

1. Check the main [README.md](./README.md)
2. Review [QUICKSTART.md](./QUICKSTART.md)
3. Run the validation: `python test-setup.py`
4. Check if ports 3000 and 8000 are available