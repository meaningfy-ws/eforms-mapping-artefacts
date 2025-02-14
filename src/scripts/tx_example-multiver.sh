#!/bin/bash

# transform SDK example reference data for all versions based on the type

# you probably need to change this
rmlmapper="$HOME/.rmlmapper/rmlmapper-6.2.2-r371-all.jar"
rmlmapper_cmd="java -jar $rmlmapper"

# Function to display help message
show_help() {
    echo "Usage: $0 -t|--type <type>"
    echo "Options:"
    echo "  -t, --type         Specify the type of transformation. Must be 'cn', 'can', or 'pin'."
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

# (re)create the pre-requisite temporary versioned mapping folders
bash scripts/prep-multiver.sh

# Validate the type argument
if [[ -z "$type" ]]; then
    echo "Error: type must be provided to determine the correct profile of rules to select"
    show_help
    exit 1
else
    # Convert type to lowercase for case-insensitive comparison
    type=$(echo "$type" | tr '[:upper:]' '[:lower:]')
    if [[ "$type" != "cn" && "$type" != "can" && "$type" != "pin" ]]; then
        echo "Error: type must be either 'cn', 'can', or 'pin'"
        exit 1
    fi
fi

# Check if at least one data file exists for the specified type
data_file_pattern="data/${type}*_24_maximal*.xml"
if ! ls $data_file_pattern 1> /dev/null 2>&1; then
    echo "Error: No version of example data for $type found."
    exit 1
fi

# Define additional mappings if type is not 'cn'
additional_mappings=""
if [[ "$type" != "cn" ]]; then
    additional_mappings="mappings-${type}/*"
fi

# Transform SDK example reference data for all versions
for i in $(ls -dv mappings-1*); do
    echo "Transforming $i for type $type"
    version=${i/mappings-}
    data_name="${type}_24_maximal"

    if [[ "$type" = "pin" ]]; then
        data_name="${type}-only_24_maximal"
    fi

    data_file="data/$data_name-$version.xml"

    # Check if the specific data file exists
    if [[ ! -f "$data_file" ]]; then
        echo "Warning: No v$version example data for $type exists, skipping.."
        continue
    fi

    cp -v "$data_file" data/source.xml
    $rmlmapper_cmd -m mappings/* $additional_mappings mappings-common/* $i/* -s turtle > output-versioned/$data_name-$version.ttl
    rm -fv data/source.xml
done
