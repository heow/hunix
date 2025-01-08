#!/bin/bash

if [ -z $1 ]; then
  targetdir=$PWD
else
  targetdir=$1
fi

# non-destructively link to files
for f in ${targetdir}/.[abcdefghijklmnopqrstuvxwyzABCDEFGHIJKLMNOPQRSTUVWXYZ]*; do

    shortfile=${f##/*/}

    if [ -h "${HOME}/${shortfile}" ]; then     # file exists and is a symlink?
        echo "already symlinked  ${shortfile}"
    elif [ -d "${HOME}/${shortfile}" ]; then   # file exists and is a dir?
        echo "ignore             ${shortfile}"
    elif [ -f "${HOME}/${shortfile}" ]; then   # file exists and is a file?
        echo "ignore             ${shortfile}"        
    else
        echo "linking            ${HOME}/${shortfile}"
        ln -i -s $f ${HOME}/${shortfile}
    fi
done
