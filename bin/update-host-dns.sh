#!/bin/bash

HOST=`hostname`

grep ${HOST} ~/.hunix/etc/hosts-dns-dme | while read LINE; do
  (IFS=" "; set -- $(echo "${LINE}")
    echo "DNS host: ${HOST} device: $2 dme id: $3 domain: $4";
    dnsmadeeasy-update.sh $2 $3
  )
done 