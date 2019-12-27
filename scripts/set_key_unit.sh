#!/bin/bash
root=`dirname $0`
cd $root/..

if [ x$1 = x-reset ]
then
    cp branch/bimodal.bpred.cpp branch/branch_predictor.cc
    cp prefetcher/no.l1i_pref.cpp prefetcher/l1i_prefetcher.cc
    cp prefetcher/no.l1d_pref.cpp prefetcher/l1d_prefetcher.cc
    cp prefetcher/no.l2c_pref.cpp prefetcher/l2c_prefetcher.cc
    cp prefetcher/no.llc_pref.cpp prefetcher/llc_prefetcher.cc
    cp replacement/lru.llc_repl.cpp replacement/llc_replacement.cc
    exit 0
fi

# ChampSim configuration
BRANCH=perceptron
L1I_PREFETCHER=next_line
L1D_PREFETCHER=next_line
L2C_PREFETCHER=kpcp
LLC_PREFETCHER=next_line
LLC_REPLACEMENT=lru

# Sanity check
if [ ! -f ./branch/${BRANCH}.bpred.cpp ]; then
    echo "[ERROR] Cannot find branch predictor"
	echo "[ERROR] Possible branch predictors from branch/*.bpred.cpp "
    find branch -name "*.bpred.cpp"
    exit 1
fi

if [ ! -f ./prefetcher/${L1I_PREFETCHER}.l1i_pref.cpp ]; then
    echo "[ERROR] Cannot find L1I prefetcher"
	echo "[ERROR] Possible L1I prefetchers from prefetcher/*.l1i_pref.cpp "
    find prefetcher -name "*.l1i_pref.cpp"
    exit 1
fi

if [ ! -f ./prefetcher/${L1D_PREFETCHER}.l1d_pref.cpp ]; then
    echo "[ERROR] Cannot find L1D prefetcher"
	echo "[ERROR] Possible L1D prefetchers from prefetcher/*.l1d_pref.cpp "
    find prefetcher -name "*.l1d_pref.cpp"
    exit 1
fi

if [ ! -f ./prefetcher/${L2C_PREFETCHER}.l2c_pref.cpp ]; then
    echo "[ERROR] Cannot find L2C prefetcher"
	echo "[ERROR] Possible L2C prefetchers from prefetcher/*.l2c_pref.cpp "
    find prefetcher -name "*.l2c_pref.cpp"
    exit 1
fi

if [ ! -f ./prefetcher/${LLC_PREFETCHER}.llc_pref.cpp ]; then
    echo "[ERROR] Cannot find LLC prefetcher"
	echo "[ERROR] Possible LLC prefetchers from prefetcher/*.llc_pref.cpp "
    find prefetcher -name "*.llc_pref.cpp"
    exit 1
fi

if [ ! -f ./replacement/${LLC_REPLACEMENT}.llc_repl.cpp ]; then
    echo "[ERROR] Cannot find LLC replacement policy"
	echo "[ERROR] Possible LLC replacement policy from replacement/*.llc_repl.cpp "
    find replacement -name "*.llc_repl.cpp"
    exit 1
fi

# Change prefetchers and replacement policy
cp branch/${BRANCH}.bpred.cpp branch/branch_predictor.cc
cp prefetcher/${L1I_PREFETCHER}.l1i_pref.cpp prefetcher/l1i_prefetcher.cc
cp prefetcher/${L1D_PREFETCHER}.l1d_pref.cpp prefetcher/l1d_prefetcher.cc
cp prefetcher/${L2C_PREFETCHER}.l2c_pref.cpp prefetcher/l2c_prefetcher.cc
cp prefetcher/${LLC_PREFETCHER}.llc_pref.cpp prefetcher/llc_prefetcher.cc
cp replacement/${LLC_REPLACEMENT}.llc_repl.cpp replacement/llc_replacement.cc
