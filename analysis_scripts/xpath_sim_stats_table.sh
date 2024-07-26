#!/bin/bash

for i in $(grep Score ref/eForms-SDK/diffs/* | sed 's/.*Ratio): //' | sort | uniq | sort -nr); do
	for f in $(grep "Score.*$i" ref/eForms-SDK/diffs/* -l); do
		echo -n "$i,"
		echo -n "$(basename ${f/.diff})" | sed 's/_v.*//' && echo -n ","
		delXpath=$(grep '^-.*xpathAbsolute' $f | sed 's/.*xpathAbsolute": //')
		echo -n "$delXpath"
		addXpath=$(grep '^+.*xpathAbsolute' $f | sed 's/.*xpathAbsolute": //')
		echo "$addXpath"
	done
done | uniq
