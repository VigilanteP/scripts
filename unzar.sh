#!/bin/bash

# Create output directories
mkdir -p .unzipped .unrared Extracted

# Find and extract zip files
find . -type f -name '*.zip' -exec sh -c 'output_dir=".unzipped/$(dirname "{}")" && mkdir -p "$output_dir" && 7z x -o"$output_dir" "{}"' \;

# Find and extract rar files
find . -type f -name '*.rar' -exec sh -c 'output_dir=".unrared/$(dirname "{}")" && mkdir -p "$output_dir" && 7z x -o"$output_dir" "{}"' \;

# Copy the contents of .unzipped and .unrared directories to Extracted folder
find .unzipped .unrared -type d -exec sh -c 'output_dir="Extracted/$(dirname "{}")" && mkdir -p "$output_dir" && cp -r "{}" "$output_dir"' \;
