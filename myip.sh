#!/bin/bash
namestr=`uname`
if [[ "$namestr" == 'Linux' ]]; then
    ip a | grep -v docker0 | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'    
    #hostname -I | cut -f 1 -d " "
    #ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'
    exit
fi

# osx
if [[ "$namestr" == 'Darwin' ]]; then
  /sbin/ifconfig | grep 'inet ' | grep -v '127.0.0.1' | head -n1 | awk '{print $2}'
  exit
fi
