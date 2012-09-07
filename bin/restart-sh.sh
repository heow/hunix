#!/bin/sh
while true; do
  echo -n "process started: "; date
  $2
  sleep $1
  echo -n "process stopped: "; date
done