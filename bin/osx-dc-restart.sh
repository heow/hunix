#!/bin/sh
echo "restarting OSX DoubleCommand system service..."
sudo /Library/StartupItems/DoubleCommand/DoubleCommand stop
sudo /Library/StartupItems/DoubleCommand/DoubleCommand start
