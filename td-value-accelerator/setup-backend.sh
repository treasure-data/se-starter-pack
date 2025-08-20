#!/bin/bash

# Create and activate virtual environment
echo "Creating virtual environment..."
python -m venv venv

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip

# Install requirements
echo "Installing Python dependencies..."
cd server && pip install -r requirements.txt

echo "Backend setup complete!"
echo "To activate the virtual environment in the future, run: source venv/bin/activate"
echo "To run the server, run: cd server && python main.py"