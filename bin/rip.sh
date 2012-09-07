#!/bin/bash

pushd ~/res/music/streams

streamripper http://184.154.177.178:54102 -d ClubKydz -s -u "gnome-vfs/2.10.0" &
streamripper http://207.200.96.231:8012   -d SpaceStationSoma -s -u "gnome-vfs/2.10.0" &
popd
