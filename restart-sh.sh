#!/bin/bash
if [ -z "$2" ] ; then
    echo "usage restart.sh 4 foo"
    echo "  every 4 seconds run foo"
    exit
fi
while true; do
  echo -n "process started: "; date
  $2 $3 $4 $5 $6
  sleep $1
  echo -n "process stopped: "; date
done
