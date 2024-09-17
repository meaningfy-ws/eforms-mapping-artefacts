#!/bin/bash

# transform all data for all CN packages

for i in $(ls -dv mappings/package_cn_*); do (cd $i && echo $i && ../../src/scripts/tx_package.sh .); done
