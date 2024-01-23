#!/bin/bash

# Function to extract archives using 7z directly into the same directory as the source archive
extract_archives() {
    local path="$1"
    find "$path" -type f \( -name "*.zip" -o -name "*.rar" \) -print0 | while IFS= read -r -d $'\0' file; do
        # Determine the output directory based on whether the file is in .extracted
        local output_dir
        if [[ "$file" == .extracted/* ]]; then
            output_dir="${file%/*}"  # Use the parent directory of the archive
        else
            local relative_path="${file#./}" # Strip leading ./
            output_dir=".extracted/${relative_path%.*}"
        fi
        
        # Create the directory and extract the file
        mkdir -p "$output_dir"
        echo "Extracting $file into $output_dir"
        7z x "$file" -o"$output_dir/" && echo "Extracted $file"
        
        # Delete the archive if it's in the .extracted directory
        if [[ "$file" == .extracted/* ]]; then
            rm "$file"
            echo "Deleted $file"
        fi
    done
}

# Main script starts here
mkdir -p .extracted

# Extract archives from the current directory
extract_archives .

# Recursively extract nested archives in .extracted
while find .extracted -mindepth 1 -type f \( -name "*.zip" -o -name "*.rar" \) -print0 | read -r -d $'\0' line; do
    extract_archives .extracted
done

echo "Extraction complete."
