#!/bin/bash
pushd ~/.hunix/bin
git-pull user@sushi:/home/heow/.hunix/bin master
popd

pushd  ~/etc
git-pull user@sushi:/home/heow/etc master
popd

pushd  ~/prj-personal/doc-wiki
git-pull user@sushi:/home/heow/prj-personal/doc-wiki master
popd

pushd  ~/prj-work/doc-wiki
git-pull user@sushi:/home/heow/prj-work/doc-wiki master
popd

TARGETUSER=user
TARGETHOST=sushi

LOCALDIR='/home/heow/res/erotica/ph/'
TARGETDIR='/home/user/res/erotica/ph/'
echo ""
echo "COPYING ${TARGETDIR} <--"
rsync --safe-links -Clavuz ${TARGETUSER}@${TARGETHOST}:${TARGETDIR} ${LOCALDIR}

exit

LOCALDIR='/home/heow/prj-personal/lispnyc/'
TARGETDIR='/home/user/prj-personal/lispnyc/'
echo ""
echo "COPYING ${TARGETDIR} <--"
rsync --safe-links -Clavuz ${TARGETUSER}@${TARGETHOST}:${TARGETDIR} ${LOCALDIR}

LOCALDIR='/home/heow/prj-personal/doc-wiki/'
TARGETDIR='/home/user/prj-personal/doc-wiki/'
echo ""
echo "COPYING ${TARGETDIR} -->"
rsync --safe-links -Cavuz ${LOCALDIR} ${TARGETUSER}@${TARGETHOST}:${TARGETDIR}

echo ""
echo "COPYING ${TARGETDIR} <--"
rsync --safe-links -Clavuz ${TARGETUSER}@${TARGETHOST}:${TARGETDIR} ${LOCALDIR}

LOCALDIR='/home/heow/prj-work/doc-wiki/'
TARGETDIR='/home/user/prj-work/doc-wiki/'
echo ""
echo "COPYING ${TARGETDIR} -->"
rsync --safe-links -Cavuz ${LOCALDIR} ${TARGETUSER}@${TARGETHOST}:${TARGETDIR}

LOCALDIR='/home/heow/bin/'
TARGETDIR='/home/user/bin/'
echo ""
echo "COPYING ${TARGETDIR} -->"
rsync --safe-links -Cavuz ${LOCALDIR} ${TARGETUSER}@${TARGETHOST}:${TARGETDIR}

echo ""
echo "COPYING ${TARGETDIR} <--"
rsync --safe-links -Clavuz ${TARGETUSER}@${TARGETHOST}:${TARGETDIR} ${LOCALDIR}

LOCALDIR='/home/heow/etc/'
TARGETDIR='/home/user/etc/'
echo ""
echo "COPYING ${TARGETDIR} -->"
rsync --safe-links -Cavuz ${LOCALDIR} ${TARGETUSER}@${TARGETHOST}:${TARGETDIR}

exit
