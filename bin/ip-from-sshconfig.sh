#!/bin/bash

if [ -z "$1" ] ; then
  echo "usage: $0 hostname"
  exit 1
fi

export HOSTFILE="${HOME}/.ssh/config"
export HOSTNAME=$1

# check each line of output to see if... 
export HOSTFOUND=0
while read line ; do

  # is line commented out?
  if [ "#" == "`echo \"\${line%${line#?}}\"`" ] ; then
      continue;
  fi

  # found host?
  if echo $line | grep -i "Host.*${HOSTNAME}" > /dev/null ; then
    export HOSTFOUND=1
    continue
  fi

  # in the correct host, look for the next hostname
  if [ 1 == $HOSTFOUND ]; then
      if echo $line | grep -i Hostname > /dev/null ; then
          echo ${line}  | cut -f 2 -d " " 
          export HOSTFOUND=0
          continue
      fi
  fi
done < $HOSTFILE

