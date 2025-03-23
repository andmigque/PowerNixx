from pdf2text import PDFtoText

# Open the PDF file
with open('deb12bench.pdf', 'rb') as f:
    # Create a PDFtoText object
    pdf = PDFtoText(f)

# Extract the text from the PDF file
text = '\n'.join(pdf)

# Write the extracted text to a text file
with open('output.txt', 'w') as f:
    f.write(text)
