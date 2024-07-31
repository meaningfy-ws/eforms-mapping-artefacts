#!/bin/bash
for i in $(grep Score ref/eForms-SDK/diffs/* | sed 's/.*Ratio): //' | sort | uniq | sort -nr); do
	echo "==> Abs XPath similarity score $i"
	for f in $(grep "Score.*$i" ref/eForms-SDK/diffs/* -l); do
		echo $(basename $f)
		printf "\t" && grep --color '^-.*xpathAbsolute' $f
		printf "\t" && grep --color '^+.*xpathAbsolute' $f
	done
	echo
done
