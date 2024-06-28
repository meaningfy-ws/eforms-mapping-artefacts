#!/bin/bash

#---
# Assisted by GenAI (Google Gemini) and StackOverFlow
# Conversation: https://g.co/gemini/share/cfaab436c1be
# Starting prompt follows below
#---
# Given a folder `mappings-versioned` with files of the following naming scheme:
# 
# Lot_v1.3-1.6.rml.ttl
# Lot_v1.7+.rml.ttl
# Lot_v0.0-1.3.rml.ttl
# Lot_v1.5-1.8.rml.ttl
# 
# Suggest a shell script that distributes (copies) files according to their versions into one of these folders, and create the folders if necessary:
# 
# mappings-1.3
# mappings-1.4
# mappings-1.5
# mappings-1.6
# mappings-1.7
# mappings-1.8
# mappings-1.9
# mappings-1.10
# 
# The version specifier at the end of the file name should be inspected to check whether it falls within the bounds of a specific major version. For e.g., "v1.7+" means it can be copied into mappings-1.7, mappings-1.8, mappings-1.9 and mappings-1.10. However, "v0.0-1.3" can only go to mappings-1.3. Likewise, a file with "v1.3-1.6" can be copied into mappings-1.3, mappings-1.4, mappings-1.5 and mappings-1.6.
#---

# adapted from https://stackoverflow.com/a/4024263
ver_between() {
    # args: min, actual, max
    printf '%s\n' "$@" | sort -C -V && echo 1
}

# Define the source directory (replace with your actual path)
source_dir="mappings"

# Define the target directory prefix (no trailing slash)
target_dir_prefix="mappings"

# Define the version range
versions=( 1.3 1.4 1.5 1.6 1.7 1.8 1.9 1.10 )

# Loop through each file in the source directory
for file in "$source_dir"/*.rml.ttl; do
  # Extract filename without extension
  filename=$(basename "$file" .rml.ttl)
  echo "Processing file: $file (Filename: $filename)"

  if [[ ! $filename =~ ^.*_v ]]; then
    echo "Skipping unversioned file: $file (Filename: $filename)"
    continue
  fi

  # Extract version range
  version_range="${filename##*_v}"
  echo "  Extracted version range: $version_range"

  # Split version range (assuming format "vX.Y[-Z]")
  min_version="${version_range%%-*}"
  if [[ $version_range =~ - ]]; then
    max_version="${version_range##*-}"
  else
    # No upper limit, set max_version to a very high value (e.g., 9.9)
    max_version="9.9"

    # Remove "+" from min_version if it exists (no upper limit)
    min_version="${min_version%%+*}"
  fi

  # Loop through each target version
  for version in "${versions[@]}"; do
    echo "  Checking version: $version against range: $min_version - $max_version"

    # Check if version falls within the range using ver_between function (modified)
    if [[ $(ver_between "$min_version" "$version" "$max_version") -eq 1 ]]; then
      # Version falls within range.
      target_dir="$target_dir_prefix-$version"
      mkdir -p "$target_dir"
      echo "    Version $version falls within range. Creating directory: $target_dir"
      cp "$file" "$target_dir/"
      echo "    Copied '$file' to '$target_dir'"
    else
      # Version does NOT fall within range.
      echo "    Version $version does NOT fall within range: $min_version - $max_version"
    fi
  done
done

echo "Distribution completed!"
