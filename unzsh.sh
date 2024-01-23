#!/bin/zsh

# Create output directories
mkdir -p .unzipped .unrarred Extracted

# Find and extract zip files
find . -type f -name '*.zip' -exec 		   zsh -c 'output_dir=".unzipped/$(basename "{}" .zip)"                && mkdir -p "$output_dir" && 7zz x -o"$output_dir" "{}"' \;

# Find and extract rar files within zip files
find .unzipped -type f -name '*.rar' -exec zsh -c 'output_dir=".unrarred/$(basename "{}" .rar)" && mkdir -p "$output_dir" && 7zz x -o"$output_dir" "{}"' \;

# Find and extract remaining rar files
find . -type f -name '*.rar' ! -path "./.unzipped/*" -exec zsh -c 'output_dir=".unrarred/$(basename "{}" .rar)" && mkdir -p "$output_dir" && 7zz x -o"$output_dir" "{}"' \;

# Copy the contents of .unzipped and .unrarred directories to Extracted folder
find .unzipped .unrarred -type d -exec zsh -c 'output_dir="Extracted/$(basename "{}")" && mkdir -p "$output_dir" && cp -r "{}" "$output_dir"' \;
