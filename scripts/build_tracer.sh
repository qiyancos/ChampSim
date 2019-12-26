#! /bin/bash
objDir=obj-intel64
root=`dirname $0`
oldDir=$PWD
cd $root/../tracer
root=$PWD

if [ x$1 = x -o x$1 = -hx ]
then
    echo "Usage: $0 [Dir for pin]"
    exit 0
elif [ ! -d $1 ]
then
    echo "Error: No such directory \"$1\"."
    exit -1
else
    pinDir=$1
    case ${pinDir:0:2} in
    ..) pinDir=`echo $pinDir | sed "s%\.%$oldDir/.%"`;;
    .*) pinDir=`echo $pinDir | sed "s%\.%$oldDir%"`;;
    esac
fi

rm -rf ./$objDir
echo "--Pin Directory: $pinDir"
mkdir -p ./$objDir
make PIN_ROOT=$pinDir ./$objDir/champsim_tracer.so
ln -s $pinDir/pin ./$objDir/pin
cp $objDir/* $root/../bin/
