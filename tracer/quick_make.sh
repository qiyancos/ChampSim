#! /bin/bash
root=`dirname $0`
cd $root
root=$PWD
make PIN_ROOT=$PWD/pin-3.2-81205-gcc-linux obj-intel64/champsim_tracer.so
