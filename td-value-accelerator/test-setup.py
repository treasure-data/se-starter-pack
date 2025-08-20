#!/usr/bin/env python3
"""
Quick test script to validate the TD Value Accelerator setup
"""

def test_imports():
    """Test that all required packages can be imported"""
    try:
        import fastapi
        import uvicorn
        import pydantic
        import websockets
        import requests
        import github
        print("✅ All required packages imported successfully")
        return True
    except ImportError as e:
        print(f"❌ Import error: {e}")
        return False

def test_fastapi_app():
    """Test that the FastAPI app can be created"""
    try:
        from server.main import app
        print("✅ FastAPI app created successfully")
        return True
    except Exception as e:
        print(f"❌ FastAPI app creation failed: {e}")
        return False

if __name__ == "__main__":
    print("Testing TD Value Accelerator setup...")
    print("=" * 50)
    
    all_tests_passed = True
    
    # Test imports
    if not test_imports():
        all_tests_passed = False
    
    # Test FastAPI app
    if not test_fastapi_app():
        all_tests_passed = False
    
    print("=" * 50)
    if all_tests_passed:
        print("🎉 All tests passed! The setup is working correctly.")
        print("\nTo start the application:")
        print("1. Frontend: npm run dev")
        print("2. Backend: npm run server")
        print("3. Or both: npm run dev:full")
    else:
        print("❌ Some tests failed. Please check the installation.")