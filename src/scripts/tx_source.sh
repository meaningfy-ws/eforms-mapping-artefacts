#!/bin/bash

# transform reference data with a versioned profile of mapping rules

# you probably need to change this
rmlmapper="$HOME/.rmlmapper/rmlmapper-6.2.2-r371-all.jar"
rmlmapper_cmd="java -jar $rmlmapper"
test_data_dir="../test_data"

# Check for the existence of the RMLMapper JAR file
if [[ ! -f "$rmlmapper" ]]; then
    echo "Error: RMLMapper not found at $rmlmapper"
    exit 1
fi

# Function to display help message
show_help() {
    echo "Usage: $0 -t|--type <type> -v|--rule-version <version> -d|--data-file <filename>"
    echo "Options:"
    echo "  -t, --type         Specify the type of transformation. Must be 'cn', 'can', or 'pin'."
    echo "  -v, --rule-version Specify the rule version to use in mappings-version. Must match the pattern '1.x' where x is a single or double-digit number."
    echo "  -d, --data-file    Specify the data file name to find under the root test_data folder."
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
        -v|--rule-version) rule_version="$2"; shift ;;
        -d|--data-file) data_file="$2"; shift ;;
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
    if [[ "$type" != "cn" && "$type" != "can" && "$type" != "pin" && "$type" != "can-modif" ]]; then
        echo "Error: type must be either 'cn', 'can', or 'pin'"
        exit 1
    fi
fi

# Validate the rule version argument
if [[ -z "$rule_version" ]]; then
    echo "Error: rule version must be provided to determine the correct version of rules to select"
    show_help
    exit 1
elif [[ ! "$rule_version" =~ ^1\.[0-9]{1,2}$ ]]; then
    echo "Error: rule version must match the pattern '1.x' where x is a single or double-digit number"
    exit 1
fi

# Check for the existence of the versioned mapping folder
if [[ ! -d "mappings-${rule_version}" ]]; then
    echo "Error: versioned folder for the given version does not exist: mappings-${rule_version}"
    exit 1
fi

# Check for the existence of the source data file
if [[ ! -f "data/source_${type}.xml" ]]; then
    echo "Error: data/source_${type}.xml not found. Transformation cannot continue due to lack of sample data file."
    exit 1
fi

bash scripts/prep-multiver.sh

# Find and copy the data file if specified
if [[ -n "$data_file" ]]; then
    found_file=$(find "$test_data_dir" -name "$data_file" -print -quit)
    if [[ -z "$found_file" ]]; then
        echo "Error: data file '$data_file' not found in $test_data_dir directory."
        exit 1
    fi
    echo "Copying data file '$found_file' to 'data/source_${type}.xml'"
    cp "$found_file" "data/source_${type}.xml"
fi

# Check CustomizationID version
customization_id=$(grep CustomizationID "data/source_${type}.xml" | sed -e 's/.*CustomizationID>eforms-sdk-//' -e 's/<\/.*CustomizationID.*//')
if [[ "$customization_id" != "$rule_version" ]]; then
    echo "WARNING: CustomizationID version 'eforms-sdk-$customization_id' does not match the passed version '$rule_version'."
fi

echo -n "Transforming reference $(echo "$type" | tr '[:lower:]' '[:upper:]') source, version $rule_version, full form.."

# Add additional mappings folder for types other than "cn"
additional_mappings=""
if [[ "$type" != "cn" ]]; then
    additional_mappings="mappings-${type/-modif/}/*"
fi

cp data/source_${type}.xml data/source.xml && $rmlmapper_cmd -m mappings/* $additional_mappings mappings-common/* mappings-${rule_version}/* -s turtle > output-${type}.ttl && rm data/source.xml
echo "done (see output-${type}.ttl)"
