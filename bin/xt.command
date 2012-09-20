#!/bin/bash

if [ -d "/Applications/iTerm.app" ]; then
  open -n "/Applications/iTerm.app"
fi

if [ ! -z "$1" ] ; then
  cd "$1"
else
  cd $HOME
fi

#if which rxvt > /dev/null 2>&1 ; then
#    rxvt -fn 6x10 -bg black -fg white -title $USER@$HOSTNAME -ls -sl 2048 &
#    exit
#fi

#if which gnome-terminal > /dev/null 2>&1 ; then
#    gnome-terminal --title=$USER@$HOSTNAME --hide-menubar 
#    exit
#fi

#if which terminator > /dev/null 2>&1 ; then
#    # geo is in PIXELS not colsxrows
#    terminator --geometry=500x300 --title=$USER@$HOSTNAME 
#    exit
#fi

xterm -fn 6x12 -title $USER@$HOSTNAME -ls &
#xterm -fg gray50 -bg grey5 -cr white -title $USER@$HOSTNAME -ls +sb -fn 6x12 -sl 1024 &
