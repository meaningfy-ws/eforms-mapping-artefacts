#!/bin/bash

# Given an eForms node (ND) compare a given min version
# to a reference version (hardcoded to 1.9.1 currently).
# Optionally, also compare the min against a max version,
# and the max against the reference.

# eForms SDK folder (as it is checked out from GitHub)
SDK_DIR=../eForms-SDK # relative to this project root

# $1: BT ID, $2: Min SDK Version, $3: Max SDK Version (optional)
eforms_node_diff() {
    [[ -z $1 || -z $2 ]] && echo "usage: <bt> <minver> [maxver]" && return 1
    bt=$1; min=$2; max=$3; ref=1.9.1
    earliest=$(git tag -l | grep $min | head -n1)
    old=$(git co -q $earliest && cat fields/fields.json | jq -r --arg ID "$bt" '.xmlStructure[] | select(.id == $ID)')
    new=$(git co -q 1.9.1 && cat fields/fields.json | jq -r --arg ID "$bt" '.xmlStructure[] | select(.id == $ID)')
    echo "==> Diff of earliest min $min ($earliest) vs. reference 1.9.1"
    echo
    diff -u --color <(echo "$old") <(echo "$new")
    echo
    if [[ -n $3 ]]; then
        latest=$(git tag -l | grep $max | tail -n1)
        mid=$(git co -q $latest && cat fields/fields.json | jq -r --arg ID "$bt" '.xmlStructure[] | select(.id == $ID)')
        echo "==> Diff of latest max $max ($latest) vs. reference 1.9.1"
        echo
        diff -u --color <(echo "$mid") <(echo "$new")
        echo
        echo "==> Diff of earliest min $min ($earliest) vs. latest max $max ($latest)"
        echo
        diff -u --color <(echo "$old") <(echo "$mid")
    fi
}

(cd $SDK_DIR && eforms_node_diff $@)
