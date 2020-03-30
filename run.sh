#!/bin/bash

source="$1"
sink="$2"

mkdir -p tmp/

./tests/set1.sh $source $sink &> tmp/s1.output
./tests/set2.sh $source $sink &> tmp/s2.output
./tests/set3.sh $source $sink &> tmp/s3.output

sed -n '/Cases:/,$p' tmp/s1.output | tail -n+2
sed -n '/Cases:/,$p' tmp/s2.output | tail -n+2
sed -n '/Cases:/,$p' tmp/s3.output | tail -n+2
