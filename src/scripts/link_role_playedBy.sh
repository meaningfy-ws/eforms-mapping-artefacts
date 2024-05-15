#!/bin/bash

# brute-force solution to linking missing playedBy for touchpoint roles
# WARNING: proof-of-concept, for one source file only, not a function

# dependencies:
#   jena-arq
#   xmlstarlet

# Reference commands:
# java -cp ~/.rmlmapper/saxon/saxon-he-12.4.jar net.sf.saxon.Query -s:src/data/source.xml -qs:"/*/ext:UBLExtensions/ext:UBLExtension/ext:ExtensionContent/efext:EformsExtension/efac:Organizations/efac:Organization[efac:TouchPoint/cac:PartyIdentification/cbc:ID[/*/cac:ProcurementProjectLot[cbc:ID/@schemeName='Lot']/cac:TenderingTerms/cac:FiscalLegislationDocumentReference/cac:IssuerParty/cac:PartyIdentification/cbc:ID]]/efac:Company/cac:PartyIdentification/cbc:ID"
# xmlstarlet sel -t -v "/*/ext:UBLExtensions/ext:UBLExtension/ext:ExtensionContent/efext:EformsExtension/efac:Organizations/efac:Organization[efac:TouchPoint/cac:PartyIdentification/cbc:ID[/*/cac:ProcurementProjectLot[cbc:ID/@schemeName='Lot']/cac:TenderingTerms/cac:FiscalLegislationDocumentReference/cac:IssuerParty/cac:PartyIdentification/cbc:ID]]/efac:Company/cac:PartyIdentification/cbc:ID" src/data/source.xml

SOURCE=src/data/source.xml
OUTPUT=src/output.ttl
QUERY=test_queries/test_missing_playedBy.rq
TMPDIR=tmp/$(basename ${SOURCE/.xml})
OUTDIR=output/$(basename ${SOURCE/.xml})
LOADFILE=$OUTDIR/link_role_playedBy.ttl

echo "Querying for roles with contact points not linked to any organization"
TPOLIST=$(arq --query $QUERY --data $OUTPUT --results csv | tail -n +2)

# this is for the final output generated at the end
mkdir -p $OUTDIR
cat <<EOF> $LOADFILE
PREFIX epd: <http://data.europa.eu/a4g/resource/>
PREFIX epo: <http://data.europa.eu/a4g/ontology#>
EOF

for i in $TPOLIST; do
  RES=$(echo $i |awk -F ',' '{print $1}')
  TPO=$(echo $i |awk -F ',' '{print $2}')

  # clean the strings (otherwise produces weird results if appended to, quick and dirty but brittle way for now)
  RES=${RES//[^a-zA-Z0-9_-:/]}
  TPO=${TPO//[^a-zA-Z0-9_-]}

  echo -n "Finding $TPO related Organization in the source data $SOURCE ... "
  ORG=$(xmlstarlet sel -t -v "/*/ext:UBLExtensions/ext:UBLExtension/ext:ExtensionContent/efext:EformsExtension/efac:Organizations/efac:Organization[efac:TouchPoint/cac:PartyIdentification/cbc:ID[text()='$TPO']]/efac:Company/cac:PartyIdentification/cbc:ID" $SOURCE)
  echo $ORG

  echo "Dumping CONSTRUCT query file for $TPO -> $ORG in $TMPDIR/construct_$TPO"

  mkdir -p $TMPDIR
cat <<EOF> $TMPDIR/construct_$TPO.rq
PREFIX epd: <http://data.europa.eu/a4g/resource/>
PREFIX epo: <http://data.europa.eu/a4g/ontology#>
PREFIX adms: <http://www.w3.org/ns/adms#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

CONSTRUCT {
  <$RES> epo:playedBy ?s
}
WHERE {
  ?s adms:identifier/skos:notation "$ORG"
}
EOF

  echo "Generating new statements for $TPO -> $ORG in $LOADFILE"
  arq --query $TMPDIR/construct_$TPO.rq --data $OUTPUT | grep -v '@prefix' >> $LOADFILE

  echo "done"
done
