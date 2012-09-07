#!/bin/sh
/sbin/ifconfig |grep "inet addr:"|cut -f2 -d:|awk '{print $1}'|grep -v 127.0.0.1
