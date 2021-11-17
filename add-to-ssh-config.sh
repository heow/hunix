#!/bin/bash
##
## addhost.sh
## 
## Made by heow
## Login   <heow@buta.lispfu.com>
## 
## Started on  Thu Jun  5 14:09:04 2008 heow
## Last update Thu Jun  5 14:09:04 2008 heow
##

if [ -z "$2" ] ; then
  echo "usage: $0 ipaddress hostname"
  exit 1
fi

export HOSTFILE="${HOME}/.ssh/config"
export IPADDR=$1
export HOSTNAME=$2
export TMPFILE=`mktemp addhost.XXXXXXX`

# check each line of output to see if... 
export EDITED=0
export HOSTFOUND=0
while read line ; do

  # is line commented out?
  if [ "#" == "`echo \"\${line%${line#?}}\"`" ] ; then
      echo "$line" >> $TMPFILE
      continue;
  fi

  # found host?
  if echo $line | grep -i "Host.*${HOSTNAME}" > /dev/null ; then
#    echo $* >> $TMPFILE
#    export EDITED=1
    export HOSTFOUND=1
    echo "${line}" >> $TMPFILE
    continue
  fi

  # in the correct host, overwrite the next hostname (with IPADDR)
  if [ 1 == $HOSTFOUND ]; then
      if echo $line | grep -i Hostname > /dev/null ; then
          # echo "#${line}" >> $TMPFILE
          echo "Hostname ${IPADDR}" >> $TMPFILE
          export EDITED=1
          export HOSTFOUND=0
          continue
      fi
  fi

  # everything else
  echo $line >> $TMPFILE
done < $HOSTFILE

if [ 0 == $EDITED ] ; then
    echo "" >> $TMPFILE
    echo "Host ${HOSTNAME}" >> $TMPFILE
    echo "Hostname ${IPADDR}" >> $TMPFILE
fi

cp $TMPFILE $HOSTFILE
rm $TMPFILE
