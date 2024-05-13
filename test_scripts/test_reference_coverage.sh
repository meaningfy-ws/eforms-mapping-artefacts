#!/bin/bash
[[ -z $1 && -z $2 ]] && echo "error" && exit 1
for i in `grep -h '||.*_.*||' $1/* | grep -v '#' | sed -e "s/.*) || '_//" -e "s/_' ||.*//" | sort -u`; do grep -q $i $2 || echo $i not found; done
