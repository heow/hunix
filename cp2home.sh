#!/bin/sh

if [ -z $1 ]; then
  targetdir=$PWD
else
  targetdir=$1
fi

for f in $PWD/.[abcdefghijklmnopqrstuvxwyzABCDEFGHIJKLMNOPQRSTUVWXYZ]*; do

    shortfile=${f##/*/}

    if [ -h "${HOME}/${shortfile}" ]; then     # file exists and is a symlink?
        echo "already symlinked  ${shortfile}"
    elif [ -d "${HOME}/${shortfile}" ]; then   # file exists and is a dir?
        echo "link dir y/n       ${HOME}/${shortfile}"
        ~/.hunix/bin/rmd ${HOME}/${shortfile}
        if [ ! -d "${HOME}/${shortfile}" ]; then
            cp -r -i $f $HOME/
        fi
    elif [ -f "${HOME}/${shortfile}" ]; then     # file exists and is a file?
        echo "link file  y/n     ${HOME}/${shortfile}"
        cp -i  $f $HOME/
    elif [ ".svn" == "${shortfile}" ]; then
        echo "ignore             ${shortfile}"
    else
        echo "writing            ${HOME}/${shortfile}"
        cp -i  $f $HOME/
    fi
done
