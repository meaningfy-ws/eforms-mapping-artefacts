#!/bin/bash
[[ -z $1 && -z $2 ]] && echo "error" && exit 1
for i in `grep -Eh "rr:predicate +.*;$" $1/* | grep -v '#' | grep -v 'idlab' | grep -v 'rdf:type' | sed -e 's/.*rr:predicate[ ]*//' -e 's/[ ]*;/;/' -e 's/;$//' | sort -u`; do grep -q $i $2 || echo $i not found; done
