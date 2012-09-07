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

export HOSTFILE="/etc/hosts"
export IPADDR=$1
export HOSTNAME=$2
export TMPFILE=`mktemp -p /tmp addhost.XXXXXXX`

# check each line of output to see if... 
export EDITED=0
while read line ; do

  # is line commented out?
  if [ "#" == "`echo \"\${line%${line#?}}\"`" ] ; then
      echo "$line" >> $TMPFILE
      continue;
  fi

  # is the hostname already in there?
  if echo $line | grep "\ $HOSTNAME" > /dev/null ; then
#    echo $* >> $TMPFILE
#    export EDITED=1
    echo "#${line}" >> $TMPFILE
    continue
  fi

  # is the ip already in use?
  if echo $line | grep "^${IPADDR}\ " > /dev/null ; then
    echo "#${line}" >> $TMPFILE
    continue
  fi

  # everything else
  echo $line >> $TMPFILE
done < $HOSTFILE

if [ 0 == $EDITED ] ; then
    echo $* >> $TMPFILE
fi

sudo cp $TMPFILE $HOSTFILE
rm $TMPFILE
