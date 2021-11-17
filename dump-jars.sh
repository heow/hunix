#!/bin/bash
echo "" > ~/tmp/out.txt
for i in `find . -name "*.jar"`; do
  echo "dumping $i"
  echo $i >> ~/tmp/out.txt
  jar -tf $i >> ~/tmp/out.txt
done
less ~/tmp/out.txt