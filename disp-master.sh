#!/bin/bash
#x2vnc -west 172.22.10.116:0
kill -9 `ps -f | grep ssh | grep x2x | awk '{ print $2}'` 2>/dev/null
ssh -X heow@gobo "x2x -east -to :0"
