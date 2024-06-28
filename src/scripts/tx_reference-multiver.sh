#!/bin/bash

# transform reference data (source.xml which is a v1.9 cn_24_maximal modified
# for more coverage during development) for all versions
#
# this is only to compare impact of versioned mappings, as results across
# versions may not be correct due to the data being of a specific version
#
# WARNING: depends on versioned mappings in directories of the form
# mappings-1.$minorver


# you probably need to change these
rmlmapper="java -jar $HOME/.rmlmapper/rmlmapper-6.2.2-r371-all.jar"

for i in `ls -dv mappings-1*`; do echo "transforming $i" && $rmlmapper -m mappings/* $i/* -s turtle > output-versioned/output-${i/mappings-}.ttl; done
