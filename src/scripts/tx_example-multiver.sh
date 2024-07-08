#!/bin/bash

# transform SDK example reference data (cn_24_maximal) for all versions
#
# WARNING: depends on versioned mappings in directories of the form
# mappings-1.$minorver

rmlmapper="java -jar $HOME/.rmlmapper/rmlmapper-6.2.2-r371-all.jar"

cp -v data/source.xml data/source.xml.bak; for i in `ls -dv mappings-1*`; do echo "transforming $i" && cp -v data/cn_24_maximal-${i/mappings-}.xml data/source.xml && $rmlmapper -m mappings/* $i/* -s turtle > output-versioned/cn_24_maximal-${i/mappings-}.ttl; done; mv -v data/source.xml.bak data/source.xml
