#!/bin/bash

# requires arq and owl-cli (see Makefile), uses query gen_newLangMap.rq

[[ -z $1 ]] && echo "usage: $(basename $0) [rml-file]" && exit 1

queryfile=scripts/construct_newLangMap.rq

owlcmd="java -jar ../owlcli/owl-cli.jar"
owlcmd_params_basic="--keepUnusedPrefixes"
owlcmd_params_prefixes="-prdf -prdfs -prr=http://www.w3.org/ns/r2rml# -prml=http://semweb.mmlab.be/ns/rml# -ptedm=http://data.europa.eu/a4g/mapping/sf-rml/"
owlcmd_params_predOrder="--predicateOrder rdf:type --predicateOrder tedm:minSDKVersion --predicateOrder tedm:maxSDKVersion --predicateOrder rdfs:label --predicateOrder rdfs:comment --predicateOrder rml:logicalSource --predicateOrder rr:subjectMap --predicateOrder rr:predicateObjectMap --predicateOrder rml:source --predicateOrder rml:iterator --predicateOrder rml:referenceFormulation --predicateOrder rr:template --predicateOrder rml:reference --predicateOrder rr:class --predicateOrder rr:predicate --predicateOrder rr:objectMap --predicateOrder rml:reference --predicateOrder rml:languageMap"

arqcmd="arq --data"

$owlcmd write $owlcmd_params_basic $owlcmd_params_prefixes $owlcmd_params_predOrder <($arqcmd "$1" --query "$queryfile") | grep -v -e "@prefix" -e "DEBUG"
