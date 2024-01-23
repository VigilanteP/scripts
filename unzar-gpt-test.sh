#!/bin/bash

# Function to create a file with random data
create_raw_data() {
    local file=$1
    echo "Creating raw data file: $file"
    echo "Sample data for $file" > "$file"
}

# Function to create a compressed file using 7z
create_archive() {
    local type=$1
    local input=$2
    local output=$3

    echo "Creating $type archive: $output"
    case $type in
        zip) 7z a -tzip "$output" "$input" ;;
        rar) rar a "$output" "$input" ;;
        *) echo "Unknown archive type: $type" ;;
    esac
}

# Main script starts here
mkdir -p test_data
cd test_data

# Create raw data files
create_raw_data "file1.txt"
create_raw_data "file2.txt"

# Create .zip and .rar files containing raw data
create_archive "zip" "file1.txt" "archive1.zip"
create_archive "rar" "file2.txt" "archive2.rar"

# Create a .rar file which contains raw data, then create a .zip file containing this .rar file
create_archive "rar" "file1.txt" "nested_archive.rar"
create_archive "zip" "nested_archive.rar" "nested.zip"

# Cleanup
rm -f nested_archive.rar
rm -f file1.txt
rm -f file2.txt

echo "Test data generation complete."

cd ..
