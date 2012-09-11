#!/bin/bash
namestr=`uname`
if [[ "$namestr" == 'Linux' ]]; then
  /sbin/ifconfig |grep "inet addr:"|cut -f2 -d:|awk '{print $1}'|grep -v 127.0.0.1
  exit
fi

# osx
if [[ "$namestr" == 'Darwin' ]]; then
  /sbin/ifconfig | grep 'inet ' | grep -v '127.0.0.1' | head -n1 | awk '{print $2}'
  exit
fi
