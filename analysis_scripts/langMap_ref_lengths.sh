#!/bin/bash

# get lengths of languageMap XPath references
for i in $(grep -Ri "@languageID" src --exclude-dir=scripts | sed -e 's/.*rml:reference//' -e 's/]//'); do echo $i $(echo $i | awk -F'/' '!seen[NF]++ {print NF}'); done
