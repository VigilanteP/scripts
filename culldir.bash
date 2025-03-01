#!/bin/bash

# Ensure proper usage
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <directory> <count>"
  exit 1
fi

# Assign input arguments to variables
directory=$1
count=$2

# Validate that the first argument is a directory
if [ ! -d "$directory" ]; then
  echo "Error: $directory is not a valid directory."
  exit 1
fi

# Validate that the second argument is a non-negative number
if ! [[ "$count" =~ ^[0-9]+$ ]]; then
  echo "Error: count must be a non-negative integer."
  exit 1
fi

# Get the list of subdirectories and count them
subdirs=("$directory"/*/)
subdir_count=${#subdirs[@]}

frequency=$(basename $directory)
prefix=$(echo $frequency | cut -c 1)
prefix="${prefix^^}"
suffix=$(echo $frequency | cut -c 2-)
frequency=$prefix$suffix

echo "$frequency snapshot count: $subdir_count"
echo "$frequency snapshot limit: $count"

# If the number of subdirectories is greater than count, delete some
if (( subdir_count > count )); then
  # Calculate how many old subdirectories we need to remove
  remove_count=$((subdir_count - count))

  if (( remove_count > 1 )); then
    echo "Removing oldest $remove_count $(basename $directory) snapshots"
  else
    echo "Removing oldest $(basename $directory) snapshot"
  fi

  # Sort subdirectories by modification time and delete the oldest ones
  # We use a loop to limit deletion to required number (`remove_count`) only.
  eza -D1 -screated $directory | head -n "$remove_count" | while read -r oldest_dir; do
    echo "Deleting: $oldest_dir"
    rm -rf "$directory/$oldest_dir"
  done
else
  echo "Skipping snapshot deletion"
fi
