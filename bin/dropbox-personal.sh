#!/bin/bash
export HOME=${HOME}/.dropbox-personal
if [ "Darwin" == `uname` ]; then
    /Applications/Dropbox.app/Contents/MacOS/Dropbox &
    exit
fi
dropbox start -i
