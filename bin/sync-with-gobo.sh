#!/bin/bash

function parse-git-dirty {
  [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit (working directory clean)" ]]
}

function sync-git-host {
    HOST=$1
    DIR=$2

    pushd $DIR
    if parse-git-dirty ; then
        echo "${DIR} is git dirty, stop"
        exit
    else
        git pull $HOST:$DIR master
    fi
    popd
}

sync-git-host heow@gobo ~/.hunix/bin 
sync-git-host heow@gobo ~/.hunix/etc
sync-git-host heow@gobo ~/prj-personal/doc-wiki
sync-git-host heow@gobo ~/prj-work/doc-wiki 


TARGETUSER=heow
TARGETHOST=gobo

LOCALDIR='/home/heow/res/art-desktop/'
TARGETDIR='/home/heow/res/art-desktop/'
echo ""
echo "COPYING ${TARGETDIR} <--"
rsync --safe-links -Clavuz ${TARGETUSER}@${TARGETHOST}:${TARGETDIR} ${LOCALDIR}

LOCALDIR='/home/heow/res/books/'
TARGETDIR='/home/heow/res/books/'
echo ""
echo "COPYING ${TARGETDIR} <--"
rsync --safe-links -Clavuz ${TARGETUSER}@${TARGETHOST}:${TARGETDIR} ${LOCALDIR}

exit
