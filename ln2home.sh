#!/bin/bash

if [ -z $1 ]; then
  targetdir=$PWD
else
  targetdir=$1
fi

for f in ${targetdir}/.[abcdefghijklmnopqrstuvxwyzABCDEFGHIJKLMNOPQRSTUVWXYZ]*; do

    shortfile=${f##/*/}

    if [ -h "${HOME}/${shortfile}" ]; then     # file exists and is a symlink?
        echo "already symlinked  ${shortfile}"
    elif [ -d "${HOME}/${shortfile}" ]; then   # file exists and is a dir?
        echo "link dir           ${HOME}/${shortfile}"
        if [ ! -d "${HOME}/${shortfile}" ]; then
            ln -i -s $f ${HOME}/${shortfile}
        fi
    elif [ -f "${HOME}/${shortfile}" ]; then     # file exists and is a file?
        echo "link file          ${HOME}/${shortfile}"
        ln -i -s $f ${HOME}/${shortfile}
    elif [ ".svn" == "${shortfile}" ]; then
        echo "ignore             ${shortfile}"
    else
        echo "writing            ${HOME}/${shortfile}"
        ln -i -s $f ${HOME}/${shortfile}
    fi
done
