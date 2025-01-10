#!/bin/sh
echo -n "Express:    "
sudo expressvpn disconnect
echo "TailScale:  " 
#sudo tailscale up --accept-routes --accept-dns=true --stateful-filtering=false
sudo tailscale up
sudo tailscale status
