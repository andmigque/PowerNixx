#!/usr/bin/env python3
import sys
import subprocess
from pathlib import Path

def convert_pdf_to_txt(input_path, output_path=None):
    """
    Convert PDF to TXT using pdfplumber CLI
    :param input_path: Path to PDF file
    :param output_path: Optional output path (defaults to same location as PDF)
    """
    input_path = Path(input_path)
    if not output_path:
        output_path = input_path.with_suffix('.txt')
    
    try:
        subprocess.run(['pdfplumber', str(input_path), '--format', 'text'], stdout=open(output_path, 'w'), check=True)
        print(f"Successfully converted {input_path} to {output_path}")
    except subprocess.CalledProcessError as e:
        print(f"Error converting {input_path}: {str(e)}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: pdf_2_text.py <input_pdf> [output_txt]")
        sys.exit(1)
    
    convert_pdf_to_txt(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else None)