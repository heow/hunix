#!/bin/sh
echo -n "TailScale:  " 
sudo tailscale down
echo -n "Express:    " 
sudo expressvpn disconnect
