#!/bin/bash

if [ ! -z "$2" ]; then
  echo "(note: a mkdir error is ok if the ~/.ssh directory already exists)"
  echo "working..."
  cryptfile="$HOME/.ssh/id_$2.pub"
  if [ -a $cryptfile ]; then
    cat $cryptfile | ssh $1 'mkdir .ssh ; chmod 700 .ssh ; cat >> ~/.ssh/authorized_keys2; chmod 600 ~/.ssh/authorized_keys2; chmod go-w ~/'
    echo "ok"
  else
    echo "error, can't find: $cryptfile"
  fi
else
  echo "usage: cp-ssh-key user@hostname (rsa|dsa)"
fi
