#!/bin/bash

# transform all data for all CAN packages

for i in $(ls -dv mappings/package_can_*); do (cd $i && echo $i && ../../src/scripts/tx_package.sh .); done
