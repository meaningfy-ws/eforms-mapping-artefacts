#!/bin/bash

# analyse versioned mappings in a given conceptual mapping

[[ -z $1 ]] && echo "usage: `basename $0` [cm_file]" && exit 1

CM_SCRIPT_PATH="analysis_scripts/cm_versioned_dump.py"
FIELD_SCRIPT_PATH="analysis_scripts/eforms_field_vercmp.sh"
NODE_SCRIPT_PATH="analysis_scripts/eforms_node_vercmp.sh"
CM_PATH=$1

# assumption: CM script returns either minSDK or maxSDK non-null
for i in `python $CM_SCRIPT_PATH $CM_PATH | uniq`; do 
    minSDK=$(echo $i | awk -F',' '{print $1}')
    maxSDK=$(echo $i | awk -F',' '{print $2}')
    fieldID=$(echo $i | awk -F',' '{print $3}')

    # we don't care about any older differences if no min
    [[ -z $minSDK ]] && minSDK=$maxSDK && maxSDK=""

    if echo "$fieldID" | grep -q "^ND"; then
        bash $NODE_SCRIPT_PATH $fieldID $minSDK $maxSDK
    else
        bash $FIELD_SCRIPT_PATH $fieldID $minSDK $maxSDK
    fi
done
