#!/bin/bash

mkdir -p $PWD/../dpc3_traces
while read LINE
do
    if [ ! -f $PWD/../dpc3_traces/$LINE ]
    then
        wget -P $PWD/../dpc3_traces -c \
                http://hpca23.cse.tamu.edu/champsim-traces/speccpu/$LINE
    else echo "-- $LINE already exits. Skipped!"
    fi
done < dpc3_max_simpoint.txt
