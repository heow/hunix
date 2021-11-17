#!/bin/sh
ping 8.8.8.8 | while read pong; do echo "$(date): $pong"; done | tee -a network-status.log
