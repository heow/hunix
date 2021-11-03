#!/bin/bash

# TODO move upload filters to .sync-ignore or similar
# auto check for .git, .gitignore
# starting from source-of-record first upload and then download

echo "START synchronize cloud"

#echo "laptop ---> github    ~/.hunix/bin"
#yadm add ~/.hunix/bin       # catches additions
#yadm commit -a -m "daily sync"; yadm push

echo "laptop <--- gdrive    resources"
rclone --verbose copy heowbert-gdrive-read:/resources   ~/resources --filter="- /wiki-journal/"

exit

echo "laptop <--- gdrive    resources/livescribe"
rclone --verbose copy gdrive-read:/Livescribe+ ~/resources/livescribe

echo "laptop <--- gdrive    projects-active"
rclone --verbose copy gdrive-read:/projects-active ~/projects-active

echo "laptop <--- gdrive    projects-areas"
rclone --verbose copy gdrive-read:/projects-areas ~/projects-areas

echo "laptop <--- gdrive    zzz-archive"
rclone --verbose copy gdrive-read:/zzz-archive ~/zzz-archive

echo "laptop ---> gdrive    ~/resources/wiki-journal"
rclone --verbose copy ~/resources/wiki-journal gdrive-write:/resources/wiki-journal --filter="- .git/" --filter="- .gitignore"

echo "laptop <--- github    ATALLC/tcb.git"
pushd ~/resources/tcb
git pull
popd

echo "laptop ---> gdrive    ~/resources/tcb"
rclone --verbose copy ~/resources/tcb gdrive-write:/resources/tcb --filter="- .git/" --filter="- .gitignore"

echo "laptop ---> github    ~/resources/wiki-journal"
FILES=~/resources/wiki-journal/
pushd ${FILES} && git add .; git commit -m "daily sync"; git push;
popd


figlet UNTRACKED
# info only
echo "UNTRACKED resources"
rclone --dry-run --verbose copy ~/resources/      gdrive-read:/resources --filter="- /wiki-journal/" --filter="- /livescribe/" --filter="- /tcb/" 2>&1 | grep NOTICE | grep -v symlink

echo "UNTRACKED projects-active"
rclone --dry-run --verbose copy ~/projects-active gdrive-read:/projects-active 2>&1 | grep NOTICE | grep -v symlink

echo "UNTRACKED projects-areas"
rclone --dry-run --verbose copy ~/projects-areas  gdrive-read:/projects-areas  2>&1 | grep NOTICE | grep -v symlink

echo "STOP"
