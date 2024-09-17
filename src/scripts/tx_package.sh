#!/bin/bash

# transform all data for a given package

[[ -z $1 ]] && echo "usage: $(basename $0) [pkgdir]" && exit 1

pkgdir=$1
[[ -z $rmlmapper ]] && rmlmapper="$HOME/.rmlmapper/rmlmapper-6.2.2-r371-all.jar"
echo "$rmlmapper"

cd $pkgdir
mkdir -p data
mkdir -p output
for i in $(find test_data/ -type f -iname "*.xml"); do
    infile=$(basename $i)
    outdir=output/$(basename $(dirname $i))/$(basename ${i/.xml})
    outfile=$outdir/$(basename ${i/.xml/.ttl})
    echo "transforming $infile -> $outfile"
    mkdir -p $outdir
    cp -rv $i data/source.xml
    java -jar $rmlmapper -m transformation/mappings/* -s turtle > $outfile
done
rm -rv data
