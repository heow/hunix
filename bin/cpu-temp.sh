#!/bin/bash

flast=0
tlast=0
while [ true ]; do
#  fnow=`cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq`
#  if [ $fnow != $flast ]; then
#      echo "`date` -> $fnow"
#  fi
  
  tnow=`awk '{print $2}' /proc/acpi/thermal_zone/TZ00/temperature`
  if [ $tnow != $tlast ]; then
      echo "`date` -> $tnow C"
  fi
  
  flast=$fnow
  tlast=$tnow
  sleep 1
done

