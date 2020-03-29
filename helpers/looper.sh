#!/bin/bash

cmd="$1"

failure=0
for i in {0..9}
do
    $cmd &>/dev/null
    ((failure+=$?))
done

printf "SUCCEEDED - $((10-$failure))/10\n"
