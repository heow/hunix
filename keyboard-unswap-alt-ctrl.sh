#!/bin/sh

#dconf reset "/org/gnome/desktop/input-sources/xkb-options" 
dconf write "/org/gnome/desktop/input-sources/xkb-options" "['caps:super']"
