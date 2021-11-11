#!/bin/bash

#pushd ~/res/music/streams

streamripper http://clubkydz.com:54102 -d ClubKydz -s -u "gnome-vfs/2.10.0" &
streamripper https://ice1.somafm.com/spacestation-128-mp3 -d SpaceStationSoma -s -u "gnome-vfs/2.10.0" &

#popd
