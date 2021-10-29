#!/bin/sh

if [ "" = "${DISPLAY}" ]; then
    # no graphics, otherwise ":0" or ":localhost:10.0"
    emacs -nw $1 $2 $3 $4 
else
    # fuck bash syntax dont judge me
    emacs $1 $2 $3 $4 &
fi
