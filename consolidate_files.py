import os

def consolidate_selected_files(output_file):
    """
    Consolidate .js, .css, and .html files into a single .txt file from specific folders, excluding large or irrelevant files.

    Args:
        output_file (str): Path to the output .txt file.
    """
    # Define the specific subdirectories to include
    target_directories = [
        './client/src/components',
        './client/public',
        './client/src',
        './client/src/actions',
        './client/src/reducers',
        './client/server',
        './server/routes'
    ]
    
    # File extensions to include
    file_types = ['.js', '.css', '.html']
    
    # Maximum size of files to include (in bytes) to prevent overly large files
    max_file_size = 100 * 1024  # 100 KB
    
    with open(output_file, 'w', encoding='utf-8') as outfile:
        for directory in target_directories:
            for root, _, files in os.walk(directory):
                for file in files:
                    if any(file.endswith(ext) for ext in file_types):
                        file_path = os.path.join(root, file)
                        
                        # Skip files that are too large
                        if os.path.getsize(file_path) > max_file_size:
                            print(f"Skipping large file: {file_path}")
                            continue
                        
                        outfile.write(f'--- Start of {file_path} ---\n')
                        try:
                            with open(file_path, 'r', encoding='utf-8') as infile:
                                outfile.write(infile.read())
                        except Exception as e:
                            outfile.write(f"Error reading file: {e}\n")
                        outfile.write(f'\n--- End of {file_path} ---\n\n')

# Define the output file path
output_file = './consolidated_files.txt'

# Run the script
consolidate_selected_files(output_file)
print(f"Consolidation completed. Output saved to {output_file}")
