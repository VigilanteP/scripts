#!/bin/bash

# Specify the directory containing split files
directory="path/to/directory"

# Change to the specified directory
cd "$directory" || exit

# Find all split files in the directory
split_files=$(find . -type f)

# Function to join files in a specific order and check if the result is a valid file
join_files_and_check() {
    local files_to_join=("$@")
    local joined_filename="joined_attempt.txt"
    
    cat "${files_to_join[@]}" > "$joined_filename"
    
    # Check if the joined file is valid (e.g., by checking file size or content)
    # Add your validation logic here
    
    # For demonstration purposes, we'll check if the file size is greater than 0
    if [ -s "$joined_filename" ]; then
        echo "Valid file created by joining ${files_to_join[@]}"
        exit
    fi
}

# Generate all permutations of split files and attempt to join them
for i in $(seq 1 ${#split_files[@]}); do
    for permutation in $(eval echo {1..${#split_files[@]}}); do
        files_to_join=($(echo "$split_files" | tr ' ' '\n' | head -n $permutation | tail -n $i))
        join_files_and_check "${files_to_join[@]}"
    done
done

echo "Unable to create a valid file by joining any combination of split files"
