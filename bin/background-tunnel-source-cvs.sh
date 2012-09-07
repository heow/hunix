#!/bin/sh
echo "note that you can log in by hand by typing:"
echo "    screen -S tunnel-cvs -r"
screen -dmS tunnel-cvs tunnel-source-cvs.sh
screen   -S tunnel-cvs -p 0 -X eval 'stuff yes\015'
sleep 1
screen   -S tunnel-cvs -p 0 -X eval 'stuff access\015'
sleep 1
#screen   -S tunnel-cvs -r
