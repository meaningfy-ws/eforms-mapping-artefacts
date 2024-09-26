#!/bin/bash

# transform reference data (source.xml which is a v1.10 can_24_maximal modified
# for more coverage during development) against CAN and CN mapping rules

# you probably need to change this
rmlmapper="java -jar $HOME/.rmlmapper/rmlmapper-6.2.2-r371-all.jar"

bash scripts/prep-multiver.sh
echo -n "Transforming reference CAN source, full form.."
cp data/source_can.xml data/source.xml && $rmlmapper -m mappings-can/* mappings-common/* mappings/* mappings-1.10/* -s turtle > output-can.ttl && rm data/source.xml
echo "done (see output-can.ttl)"
