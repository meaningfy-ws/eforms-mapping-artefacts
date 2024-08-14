#!/bin/bash

# transform reference data (source.xml which is a v1.10 can_24_maximal modified
# for more coverage during development) against only CN (EF10-24) mapping rules

# you probably need to change this
rmlmapper="java -jar $HOME/.rmlmapper/rmlmapper-6.2.2-r371-all.jar"

bash scripts/prep-multiver.sh
echo -n "Transforming reference CN source, full form.."
cp data/source_cn.xml data/source.xml && $rmlmapper -m mappings/* mappings-common/* mappings-1.9/* -s turtle > output-cn.ttl && rm data/source.xml
echo "done (see output-cn.ttl)"
