#!/bin/bash

# Set of allowed values
VALID_VALUES=("hourly" "daily" "weekly" "monthly")

# Check for presence of argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 {hourly|daily|weekly|monthly}"
    exit 1
fi

frequency=$1

# Check that argument is a valid frequency
valid="false"
for value in "${VALID_VALUES[@]}"; do
    if [ "$frequency" == "$value" ]; then
        valid="true"
        break
    fi
done

if [ "$valid" == "false" ]; then
    echo "Error: Invalid argument. Expected one of: {hourly|daily|weekly|monthly}"
    exit 1
fi

data_dir=/mnt/data
snapshot_root=/mnt/snapshots
snapshot_dir=$snapshot_root/$frequency

btrfs subvolume snapshot $data_dir $snapshot_dir/$(date +"%Y-%m-%d_%H-%M-%S")
