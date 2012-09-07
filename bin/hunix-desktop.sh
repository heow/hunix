#!/bin/sh

# tmux start-server
#tmux new-session -d -s hunx-desktop -n main
#tmux new-window -t hunix-desktop:1 -n display
#tmux new-window -t hunix-desktop:2 -n servers
#tmux new-window -t hunix-desktop:3 -n logs
#
#tmux send-keys -t hunix-desktop:0 "cd $BASE; vim" C-m
#tmux send-keys -t hunix-desktop:1 "cd $BASE; guard -c" C-m
#tmux send-keys -t hunix-desktop:2 "cd $BASE; foreman start" C-m
#tmux send-keys -t hunix-desktop:3 "cd $BASE; tail -f log/*.log" C-m
#
#tmux select-window -t hunix-desktop:0
#tmux attach-session -t hunix-desktop

sawfish --replace &
find-known-hosts.sh
#sleep 5
xcompmgr &
sleep 2
cairo-dock -c &
#wallch &
disp-master.sh &
