#!/bin/sh
echo "after login:  "
echo "  ssh -p 8022 -C -L 4000:svnhome.intdata.com:80 -p 8022 heow@localhost"
sudo ssh -C -L 80:lispnyc.org:4000 heow@lispnyc.org
