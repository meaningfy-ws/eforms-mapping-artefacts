#!/bin/bash

# transform SDK example reference data (cn_24_maximal) for all versions
#
# WARNING: depends on versioned mappings in directories of the form
# mappings-1.$minorver

rmlmapper="java -jar $HOME/.rmlmapper/rmlmapper-6.2.2-r371-all.jar"

bash scripts/prep-multiver.sh
for i in `ls -dv mappings-1*`; do echo "transforming $i" && cp -v data/cn_24_maximal-${i/mappings-}.xml data/source.xml && $rmlmapper -m mappings/* mappings-common/* $i/* -s turtle > output-versioned/cn_24_maximal-${i/mappings-}.ttl && rm -fv data/source.xml; done
