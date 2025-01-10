#!/bin/sh
echo -n "TailScale:  " 
sudo tailscale down
echo "Express:    " 
sudo expressvpn connect
