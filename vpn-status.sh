#!/bin/sh
echo "VPN status..."
echo "  TailScale:  " 
tailscale status
echo -n "  Express:    "
expressvpn status 2>/dev/null
echo ""
exit 0
