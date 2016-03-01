#!/bin/bash -e

module load hugeseq/2.0
# make Hugeseq work even when not in default location
export PATH=$HUGESEQ_HOME/bin/:$PATH
export TMP=$1
echo $TMP
shift
export LOGFILE=$1
echo $LOGFILE
shift

$*
