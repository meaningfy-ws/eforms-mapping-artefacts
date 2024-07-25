#!/bin/bash

# Given an eForms node (ND) compare a given min version
# to a reference version (hardcoded to 1.9.1 currently).
# Optionally, also compare the min against a max version,
# and the max against the reference.
#
# Code almost similar to eforms_field_vercmp except
# jq lookup is with .xmlStructure[] instead of .xmlStructure[],
# so code replacements must be made at lines containing $node.
#
# Depends on Python3 script cmp_xpaths.py (requires pandas, fuzzywuzzy)

# eForms SDK folder (as it is checked out from GitHub)
[[ -z $SDK_DIR ]] && SDK_DIR=../eForms-SDK # relative path to the root of the eForms-SDK Git project

# working directory
[[ -z $WORKDIR ]] && WORKDIR="`pwd`/ref"

# fields store
[[ -z $FIELDSDIR ]] && FIELDSDIR="$WORKDIR/eForms-SDK/fields"

# diff store
[[ -z $DIFFDIR ]] && DIFFDIR="$WORKDIR/eForms-SDK/diffs"

# reference version (to always compare against)
[[ -z $REFVER ]] && REFVER="1.9.1" && ref="1.9"

# python string similarity script path
[[ -z $STRSIM_SCRIPT ]] && STRSIM_SCRIPT="`dirname $0`/cmp_xpaths.py"

mkdir -p $FIELDSDIR
mkdir -p $DIFFDIR

# $1: version string
get_local_fields_file() {
    ver=$1
    echo "$FIELDSDIR/fields_v$ver.json"
}

# $1: min version string
get_earliest_vertag() {
    minver=$1
    (cd $SDK_DIR && git tag -l | grep $minver | head -n1)
}

# $1: max version string
get_latest_vertag() {
    maxver=$1
    (cd $SDK_DIR && git tag -l | grep $maxver | tail -n1)
}

# $1: version string
get_fields_file_by_ver() {
    ver=$1
    (cd $SDK_DIR && git checkout $ver && cat fields/fields.json > "$FIELDSDIR/fields_v$ver.json")
}

# $1: diff file
get_xpath_change() {
    diff_type=$1
    diff_file=$2
    if [[ $diff_type == "old" ]]; then
        grep "^-.*xpathAbsolute" "$diff_file" | sed -e 's/.*"xpathAbsolute": //' -e 's/,//'
    elif [[ $diff_type == "new" ]]; then
        grep "^+.*xpathAbsolute" "$diff_file" | sed -e 's/.*"xpathAbsolute": //' -e 's/,//'
    else # default old
        grep "^-.*xpathAbsolute" "$diff_file" | sed -e 's/.*"xpathAbsolute": //' -e 's/,//'
    fi
}

# TODO:
# - deal with also rel XPath change when no abs change?
# - check and write something different to the diff if > 90 < 95, and something else for < 90
# $1: string1, $2: string2, $3: file to prepend score (optional)
get_xpath_similarity() {
    old_xpath=$1
    new_xpath=$2
    minver=$3
    maxver=$4
    # WARNING: remove the /dev/null pipe to debug, otherwise real errors are hidden
    echo -n "Abs XPath v$minver-$maxver " && python3 "$STRSIM_SCRIPT" $old_xpath $new_xpath 2> /dev/null
}

# $1: eForms Node ID, $2: Min SDK Version, $3: Max SDK Version (optional)
eforms_node_diff() {
    [[ -z $1 || -z $2 ]] && echo "usage: <nodeID> <minver> [maxver]" && return 1
    node=$1; min=$2; max=$3

    earliest=$(get_earliest_vertag $min)
    minver_fields_file=$(get_local_fields_file $earliest)
    test -s $minver_fields_file || get_fields_file_by_ver $earliest
    old=$(cat $minver_fields_file | jq -r --arg ID "$node" '.xmlStructure[] | select(.id == $ID)')

    refver_fields_file=$(get_local_fields_file $REFVER)
    test -s $refver_fields_file || get_fields_file_by_ver $REFVER
    new=$(cat $refver_fields_file | jq -r --arg ID "$node" '.xmlStructure[] | select(.id == $ID)')

    # any Git operations output should come first, so we run conditionally twice
    if [[ -n $3 ]]; then
        latest=$(get_latest_vertag $max)
        maxver_fields_file=$(get_local_fields_file $latest)
        test -s $maxver_fields_file || get_fields_file_by_ver $latest
        mid=$(cat $maxver_fields_file | jq -r --arg ID "$node" '.xmlStructure[] | select(.id == $ID)')
    fi

    echo "==> Diff of earliest min $min ($earliest) vs. reference $REFVER"
    echo
    DIFFFILE="$DIFFDIR/${node}_v$min-$ref.diff"
    diff -u --color <(echo "$old") <(echo "$new")
    diff -u <(echo "$old") <(echo "$new") > "$DIFFFILE"
    echo
    old_xpath=$(get_xpath_change old "$DIFFFILE")
    new_xpath=$(get_xpath_change new "$DIFFFILE")
    xpath_sim=$([[ -n $old_xpath ]] && [[ -n $new_xpath ]] && get_xpath_similarity $old_xpath $new_xpath $min $ref || echo "No Abs XPath changes in v$min-$ref")
    [[ -n $xpath_sim ]] && echo $xpath_sim && sed -i "1s/^/$xpath_sim\n/" "$DIFFFILE"
    test -s "$DIFFFILE" && echo "Saved to $DIFFFILE" || rm "$DIFFFILE"
    echo

    if [[ -n $3 ]]; then
        echo "==> Diff of latest max $max ($latest) vs. reference $REFVER"
        echo
        DIFFFILE="$DIFFDIR/${node}_v$max-$ref.diff"
        diff -u --color <(echo "$mid") <(echo "$new")
        diff -u <(echo "$mid") <(echo "$new") > "$DIFFFILE"
        echo
        old_xpath=$(get_xpath_change old "$DIFFFILE")
        new_xpath=$(get_xpath_change new "$DIFFFILE")
        xpath_sim=$([[ -n $old_xpath ]] && [[ -n $new_xpath ]] && get_xpath_similarity $old_xpath $new_xpath $max $ref || echo "No Abs XPath changes v$max-$ref")
        [[ -n $xpath_sim ]] && echo $xpath_sim && sed -i "1s/^/$xpath_sim\n/" "$DIFFFILE"
        test -s "$DIFFFILE" && echo "Saved to $DIFFFILE" || rm "$DIFFFILE"
        echo

        echo "==> Diff of earliest min $min ($earliest) vs. latest max $max ($latest)"
        echo
        DIFFFILE="$DIFFDIR/${node}_v$min-$max.diff"
        diff -u --color <(echo "$old") <(echo "$mid")
        diff -u <(echo "$old") <(echo "$mid") > "$DIFFFILE"
        echo
        old_xpath=$(get_xpath_change old "$DIFFFILE")
        new_xpath=$(get_xpath_change new "$DIFFFILE")
        xpath_sim=$([[ -n $old_xpath ]] && [[ -n $new_xpath ]] && get_xpath_similarity $old_xpath $new_xpath $min $max || echo "No Abslute XPath changes in v$min-$max")
        [[ -n $xpath_sim ]] && echo $xpath_sim && sed -i "1s/^/$xpath_sim\n/" "$DIFFFILE"
        test -s "$DIFFFILE" && echo "Saved to $DIFFFILE" || rm "$DIFFFILE"
    fi
}

eforms_node_diff $@
