#!/bin/bash

if [ x$1 = x -o x$1 = -hx ]
then
    echo "Usage: $0 [Trace List File]"
    echo "    This script is used to download the file list in given list file."
    echo "    The list can selected from \"./config/dpc3_max_simpoint.txt\"."
    exit 0
elif [ ! -f $1 ]
then
    echo "Erro: No such file or directory \"$1\"."
    exit -1
fi

mkdir -p $PWD/../dpc3_traces
while read LINE
do
    if [ ! -f $PWD/../dpc3_traces/$LINE ]
    then
        wget -P $PWD/../dpc3_traces -c \
                http://hpca23.cse.tamu.edu/champsim-traces/speccpu/$LINE
    else echo "-- $LINE already exits. Skipped!"
    fi
done < $1
