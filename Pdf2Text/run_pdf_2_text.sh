#!/bin/bash

VENV_DIR="pdf2text_env"

if [ -d "$VENV_DIR" ]; then
    echo "Found existing virtual environment, activating..."
    source $VENV_DIR/bin/activate
else
    echo "Creating new virtual environment..."
    python3 -m venv $VENV_DIR
    source $VENV_DIR/bin/activate
fi

# Install required packages
pip install pdfplumber

# Check if the script exists, if not create it
if [ ! -f "pdf_2_text.py" ]; then
    echo "PDF to text converter script not found, creating..."
    cp ../pdf_2_text.py .
fi

# Make the Python script executable
chmod +x pdf_2_text.py

if [ $# -eq 0 ]; then
    echo "Usage: ./run_pdf_2_text.sh <input_path> [output_path]"
    exit 1
fi