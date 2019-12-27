#!/bin/bash
root=`dirname $0`
cd $root/..
root=$PWD
source $root/scripts/lib/shimport $root/scripts/lib
shimport color_scheme.shh
# shimport basic_func.shh

if [ x$1 = x -o x$1 = x-h ] 
then
    echo "Usage: ./build_champsim.sh [Options] [Config Files]"
    echo "    -l, --list    List all the available branch predictors, prefetchers, replace policies"
    echo "    -b, --build   Build ChampSim with given config files."
    echo "    Config Files  Config files must be given to modify system settings."
    echo "                  default: $root/scripts/config/system.ini"
    exit 1
fi

if [ $# = 1 ] && [ $1 = -l -o $1 = --list ]
then
    name=`ls ./branch | grep "bpred.cpp" | sed 's/\.bpred\.cpp//g'`
    WARNTLN "-- Branch Predictor: "; echo $name
    name=`ls ./prefetcher | grep "l1i_pref.cpp" | sed 's/\.l1i_pref\.cpp//g'`
    WARNTLN "-- Prefetcher(L1 ICache): "; echo $name
    name=`ls ./prefetcher | grep "l1d_pref.cpp" | sed 's/\.l1d_pref\.cpp//g'`
    WARNTLN "-- Prefetcher(L1 DCache): "; echo $name
    name=`ls ./prefetcher | grep "l2c_pref.cpp" | sed 's/\.l2c_pref\.cpp//g'`
    WARNTLN "-- Prefetcher(L2 Cache): "; echo $name
    name=`ls ./prefetcher | grep "llc_pref.cpp" | sed 's/\.llc_pref\.cpp//g'`
    WARNTLN "-- Prefetcher(Last Level Cache): "; echo $name
    name=`ls ./replacement | grep "llc_repl.cpp" | sed 's/\.llc_repl\.cpp//g'`
    WARNTLN "-- Replace Policy: "; echo $name
    exit 0
elif [ x$1 = x-b -o x$1 = x--build ]
then
    if [ $# = 1 ]
    then configs=$root/scripts/config/system.ini
    else
        shift
        configs="$*"
    fi
else
    ERROR "Arguments \"$1\" not available! Use -h for help."
    exit -1
fi


RUNMSG ">> Applying Settings..."
for config in $configs
do
    opFile=`echo $config | sed 's/\(.*\)ini/\1op/'`
    if [ ! -f $config ]
    then
        ERROR "No such file or directory \"$config\""
        exit -1
    elif [ ! -f $opFile ]
    then
        ERROR "No matched operation file \"$opFIle\""
        exit -1
    fi
    source $config
    lineNum=0
    while read operation
    do
        lineNum=$[lineNum + 1]
        operation=`echo $operation | sed 's/[ \t]*\(.*\)/\1/g'`
        if [ "x$operation" = x ] || [ x${operation:0:1} = x# ] 
        then continue
        fi
        operation=(`echo $operation | sed -e 's/ /@/g' -e 's/,/ /g'`)
        paramName=`echo ${operation[0]} | sed 's/@/ /g'`
        originString=`echo ${operation[1]} | sed -e 's/@/ /g' -e 's/[ \t]*\(.*\)/\1/g'`
        targetFile=`echo ${operation[3]} | sed -e 's/@/ /g' -e 's/[ \t]*\(.*\)/\1/g'`
        paramVal=$(eval echo \$$paramName)
        newString=`echo ${operation[2]} | sed -e 's/@/ /g' -e 's/[ \t]*\(.*\)/\1/g'`
        newString=`echo $newString | sed "s/\\\\$\\\\$/$paramVal/g"`
        if [ x$paramVal = x ]
        then
            WARN "Param $paramName not defined! Operation is skipped."
            continue
        elif [ "x$targetFile" = x -o ! -f $targetFile ]
        then
            ERROR "No target file specified or file not exits \"$targetFile\""
            echo "Line $lineNum in file $opFile."
            exit -1
        fi
        echo "-- Param: $paramName; Value: $paramVal"
        if [ ${paramName:0:3} = use ]
        then
            if [[ $paramVal =~ [yY]es|[nN]o|YES|NO ]]
            then
                if [[ ${paramVal:0:1} =~ [yY] ]]
                then
                    eval "sed -i \"/$newString/c\\$originString\" $targetFile"
                    # echo sed -i \"/$newString/c\\$originString\" $targetFile
                else
                    eval "sed -i \"/$originString/c\\$newString\" $targetFile"
                    # echo sed -i \"/$originString/c\\$newString\" $targetFile
                fi
            else
                ERROR "Param $paramName illegal!"
                WARN "Param with prefix like \"use\" must be defined as Yes/No."
                exit -1
            fi
        else
            eval "sed -i \"/$originString/c\\$newString\" $targetFile"
            # echo sed -i \"/$originString/c\\$newString\" $targetFile
        fi
    done < $opFile
done
RUNMSG "-- Settings Apply Finished."
exit

source $root/scripts/set_key_unit.sh
binName="${BRANCH}-${L1I_PREFETCHER}-${L1D_PREFETCHER}"
binName="$binName-${L2C_PREFETCHER}-${LLC_PREFETCHER}"
binName="$binName-${LLC_REPLACEMENT}-${numCPUs}core-champsim"

RUNMSG "-- Building ChampSim..."
# Build
rm -f bin/champsim
make clean
mkdir -p bin
make

# Sanity check
echo ""
if [ ! -f bin/champsim ]; then
    ERROR "ChampSim build FAILED!"
    exit -1
fi

RUNMSG "-- ChampSim is successfully built."
WARNT "-- Build Detail:"
echo "    Cores: ${numCPUs}"
echo "    Branch Predictor: ${BRANCH}"
echo "    L1I Prefetcher: ${L1I_PREFETCHER}"
echo "    L1D Prefetcher: ${L1D_PREFETCHER}"
echo "    L2C Prefetcher: ${L2C_PREFETCHER}"
echo "    LLC Prefetcher: ${LLC_PREFETCHER}"
echo "    LLC Replacement: ${LLC_REPLACEMENT}"
echo ""
mv bin/champsim bin/$binName
RUNMSG "-- Saved as $root/bin/$binName"
