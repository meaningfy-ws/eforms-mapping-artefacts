#!/bin/bash

# transform reference data (source.xml which is a v1.10 can_24_maximal modified
# for more coverage during development) against only CAN (EF29) mapping rules

# you probably need to change this
rmlmapper="java -jar $HOME/.rmlmapper/rmlmapper-6.2.2-r371-all.jar"

echo -n "Transforming reference CAN source, CAN subset (partial form).."
cp data/source_can.xml data/source.xml && $rmlmapper -m mappings-can/* mappings-common/* -s turtle > output-canonly.ttl && rm data/source.xml
echo "done (see output-canonly.ttl)"
