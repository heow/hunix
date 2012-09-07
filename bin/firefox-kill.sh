#!/bin/sh
killall firefox firefox-bin run-mozilla.sh
find ~/.mozilla/firefox -name .parentlock -exec rm {} \;
find ~/.mozilla/firefox -name lock -exec rm {} \;