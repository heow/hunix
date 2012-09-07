#!/bin/sh

# todo: make multi-file aware

if [ -z "$1" ]; then
    echo "missing source file, copies to PWD"
    exit 1
fi

TARGETHOST=`echo $1 | cut -d ":" -f 1`
TARGETFILE=`echo $1 | cut -d ":" -f 2`

#echo $TARGETHOST
#echo $TARGETFILE

# these will be the same if ":" is missing
CMD="cat \"${TARGETFILE}\" | split -b 4000m - `basename ${TARGETFILE}`.";
if [ "$TARGETHOST" != "$TARGETFILE" ]; then
  CMD="ssh -c blowfish ${TARGETHOST} ${CMD}"
fi
eval $CMD
