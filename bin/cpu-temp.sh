#!/bin/bash
if  which sensors > /dev/null 2>&1 ; then
    sensors
else
    echo "instal lm-sensor package"
    sudo apt-get install git
fi
