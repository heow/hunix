#!/bin/bash
##
## find-known-hosts.sh
## 
## Made by heow
## Login   <heow@buta.lispfu.com>
## 
## Started on  Thu Jun  5 16:26:25 2008 heow
## Last update Thu Jun  5 16:26:25 2008 heow
##

ROOT=0
if [ -n "$1" ] ; then
  echo "updating using /etc/hosts"
  ROOT=1
fi

if [ "0" == `id -u` ]; then # running as root?
  echo "updating using /etc/hosts"
  ROOT=1
fi

# hosts file
if [ -s "/etc/hosts-mac" ]; then
  ETCFILE="/etc/hosts-mac"
fi

if [ -s "${HOME}/.hunix/etc/hosts-mac" ]; then
  ETCFILE="${HOME}/.hunix/etc/hosts-mac"
fi

echo "Using MAC addresses from ${ETCFILE}"

# ping our local network
export LOCALNET=`myip.sh | cut -f 1-3 -d "."`
fping -g "${LOCALNET}.0/24" 2> /dev/null 

# check the arp table for the known MACs
while read LINE ; do
    export MAC=`echo $LINE | cut -d " " -f 1 | tr "[A-Z]" "[a-z]"`
    # osx needs leading 0s added to mac
    if [[ "Darwin" == `uname` ]]; then
        MAC=`echo $MAC | sed -e 'y/ABCDEF/abcdef/' -e 's/0\([0-9a-f]\)/\1/g'`
    fi
    export HOSTS=`echo $LINE | cut -d " " -f 2-`
    export IP=`arp -n -a | grep $MAC | cut -d " " -f 2 | cut -d "(" -f 2 | cut -d ")" -f 1 | tr "[A-Z]" "[a-z]"`
    if [ -z "$IP" ] ; then
        continue
    fi
    echo "found `echo $HOSTS | cut -d " " -f 1` as $IP"

    if [ "1" == "$ROOT" ]; then
        echo "adding to /etc/hosts"
        add-to-etc-hosts.sh $IP $HOSTS
    else
        echo "adding to .ssh/config"
        add-to-ssh-config.sh $IP $HOSTS
    fi
done < $ETCFILE

# update DNS
update-host-dns.sh
