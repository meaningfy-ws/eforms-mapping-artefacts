#!/bin/bash

# transform all data for all packages based on the type

# Function to display help message
show_help() {
    echo "Usage: $0 -t|--type <type>"
    echo "Options:"
    echo "  -t, --type         Specify the type of transformation. Must be 'cn' or 'can'."
    echo "  -h, --help         Display this help message."
}

# Parse input arguments
if [[ "$#" -eq 0 ]]; then
    show_help
    exit 1
fi

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -t|--type) type="$2"; shift ;;
        -h|--help) show_help; exit 0 ;;
        *) echo "Unknown parameter passed: $1"; show_help; exit 1 ;;
    esac
    shift
done

# Validate the type argument
if [[ -z "$type" ]]; then
    echo "Error: type must be provided to determine the correct profile of rules to select"
    show_help
    exit 1
else
    # Convert type to lowercase for case-insensitive comparison
    type=$(echo "$type" | tr '[:upper:]' '[:lower:]')
    if [[ "$type" != "cn" && "$type" != "can" ]]; then
        echo "Error: type must be either 'cn' or 'can'"
        exit 1
    fi
fi

# Transform all data for all packages of the specified type
for i in $(ls -dv mappings/package_${type}_*); do
    (cd $i && echo "Processing package: $i" && ../../src/scripts/tx_package.sh .)
done
