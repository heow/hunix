#!/bin/bash

publish-muse.sh

export TARGETHOSTNAME=h2d2
export TARGETHOST=`ip-from-sshconfig.sh ${TARGETHOSTNAME}`
if ping -c 3 ${TARGETHOST} >> /dev/null ; then
  echo "${TARGETHOSTNAME} at ${TARGETHOST}"
else
  echo "${TARGETHOSTNAME} not found at ${TARGETHOST}"
  exit 1
fi

LOCALDIR='/home/heow/res/doc/wiki-personal/'
TARGETDIR='/sdcard/'
echo ""
echo "COPYING ${TARGETDIR} -->"
scp -r ${LOCALDIR} ${TARGETHOSTNAME}:${TARGETDIR}

LOCALDIR='/home/heow/res/doc/wiki-work/'
TARGETDIR='/sdcard/'
echo ""
echo "COPYING ${TARGETDIR} -->"
scp -r ${LOCALDIR} ${TARGETHOSTNAME}:${TARGETDIR}
