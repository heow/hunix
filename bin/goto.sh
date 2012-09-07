#!/bin/sh
A=`locate $1|head -1`
if [ -n "$A" ]; then
    cd `dirname $A`
    pwd
else
    echo "."
fi