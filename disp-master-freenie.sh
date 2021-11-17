#!/bin/bash
#x2vnc -west 172.22.10.116:0
#kill -9 `ps -f | grep ssh | grep x2x | awk '{ print $2}'` 2>/dev/null
#ssh -X heow@gobo "x2x -east -to :0"
echo "config via syn gui, start, 'ps -ef | grep syn' to get the config file"
synergys -n MBP -f --config /var/folders/km/cf7gc7cs34s2pdcjy15q10gh0000gn/T/qt_temp.M18375
