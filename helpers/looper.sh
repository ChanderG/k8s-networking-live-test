#!/bin/bash

cmd="$1"

failure=0
for i in {0..9}
do
    $cmd &>/dev/null
    ((failure+=$?))
done

printf "$((10-$failure))/10 tries pass\n"
