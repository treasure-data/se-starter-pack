#!/bin/bash

echo "🚀 Starting TD Value Accelerator Development Servers..."
echo "=================================================="

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "🛑 Shutting down servers..."
    kill $FRONTEND_PID $BACKEND_PID 2>/dev/null
    exit 0
}

# Trap cleanup function on script exit
trap cleanup EXIT

# Start backend server
echo "📦 Starting Backend Server (Port 8000)..."
cd "$(dirname "$0")"
source venv/bin/activate
cd server
python main.py &
BACKEND_PID=$!

# Wait a moment for backend to start
sleep 2

# Start frontend server
echo "🎨 Starting Frontend Server (Port 3000)..."
cd ..
npm run dev &
FRONTEND_PID=$!

# Wait a moment for frontend to start
sleep 3

echo ""
echo "✅ Servers are running:"
echo "   Frontend: http://localhost:3000"
echo "   Backend:  http://localhost:8000"
echo "   API Docs: http://localhost:8000/docs"
echo ""
echo "Press Ctrl+C to stop both servers"

# Wait for user to stop
wait