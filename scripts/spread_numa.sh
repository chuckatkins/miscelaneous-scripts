#!/bin/bash

# Evenly spread a command across numa domains for a given number of CPU cores
function spread()
{
  NUM_CORES=$1
  shift

  # Use this wicked awk script to parse the numactl hardware layout and
  # select an equal number of core(s) from each NUMA domain, evenly spaced
  # across each dmain
  SPREAD="$(numactl -H | sed -n 's|.*cpus: \(.*\)|\1|p' | awk -v NC=${NUM_CORES} -v ND=${NUMA_DOMAINS} 'BEGIN{CPD=NC/ND} {S=NF/CPD; for(C=0;C<CPD;C++){F0=C*S; F1=(F0==int(F0)?F0:int(F0)+1)+1; printf("%d", $F1); if(!(NR==ND && C==CPD-1)){printf(",")} } }')"

  echo Executing: numactl --physcpubind=${SPREAD} "$@"
  numactl --physcpubind=${SPREAD} "$@"
}

# Check command arguments
if [ $# -lt 2 ]
then
  echo "Usage: $0 [NUM_CORES_TO_USE] [cmd [arg1] ... [argn]]"
  exit 1
fi

# Determine the total number of CPU cores
MAX_CORES=$(numactl -s | sed -n 's|physcpubind: \(.*\)|\1|p' | wc -w)

# Determine the total number of NUMA domains
NUMA_DOMAINS=$(numactl -H | sed -n 's|available: \([0-9]*\).*|\1|p')

# Verify the number of core(s) is sane
NUM_CORES=$1
shift
if [ $NUM_CORES -gt $MAX_CORES ]
then
  echo "WARNING: $NUM_CORES core(s) is out of bounds.  Setting to $MAX_CORES core(s)."
  NUM_CORES=$MAX_CORES
fi
if [ $((NUM_CORES%NUMA_DOMAINS)) -ne 0 ]
then
  TMP=$(( ((NUM_CORES/NUMA_DOMAINS) + 1) * NUMA_DOMAINS ))
  echo "WARNING: $NUM_CORES core(s) are not evenly divided across $NUMA_DOMAINS NUMA domain(s).  Setting to $TMP."
  NUM_CORES=$TMP
fi

echo "Using ${NUM_CORES}/${MAX_CORES} core(s) across ${NUMA_DOMAINS} NUMA domain(s)"

spread ${NUM_CORES} "$@"
