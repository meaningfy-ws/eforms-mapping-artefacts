#!/bin/bash

# transform reference data for all versions based on the type
#
# this is only to compare impact of versioned mappings, as results across
# versions may not be correct due to the data being of a specific version
#
# WARNING: depends on versioned mappings in directories of the form
# mappings-1.$minorver

# you probably need to change this
rmlmapper="$HOME/.rmlmapper/rmlmapper-6.2.2-r371-all.jar"
rmlmapper_cmd="java -jar $rmlmapper"

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

bash scripts/prep-multiver.sh

# Define additional mappings if type is not 'cn'
additional_mappings=""
if [[ "$type" != "cn" ]]; then
    additional_mappings="mappings-${type}/*"
fi

# Transform reference data for all versions
for i in $(ls -dv mappings-1*); do
    echo "Transforming $i for type $type"
    cp -v data/source_${type}.xml data/source.xml
    $rmlmapper_cmd -m mappings/* $additional_mappings mappings-common/* $i/* -s turtle > output-versioned/output-${type}-${i/mappings-}.ttl
    rm -fv data/source.xml
done
