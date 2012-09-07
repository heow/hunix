#!/bin/sh

for i in $( xlsclients -l | grep -B2 "Command: *qiv" | grep ^Window | awk '{print $2}' | awk -F: '{print $1}' ) ; do 
  xkill -id ${i} ; 
done