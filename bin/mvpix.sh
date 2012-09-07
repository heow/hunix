#!/bin/bash
if [ -z "$1" ]; then
  echo "need target directory"
  exit
fi
mv *.[Gg][Ii][Ff] *.[Jj][Pp][Gg] *.[Jj][Pp][Ee][Gg] *.[Pp][Nn][Gg] $1 2>/dev/null