#!/bin/bash
while true; do 
    sleep 30
    ping -c 3 8.8.8.8 > /dev/null 2>&1
    if [ "$?" -eq 1 ]; then
        echo "";
        echo `date +"%Y-%m-%d %H:%M"`": no connection "
    else
        echo -n "."
    fi
done