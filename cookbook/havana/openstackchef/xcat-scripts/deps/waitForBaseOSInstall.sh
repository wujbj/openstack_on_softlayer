#!/bin/bash

# Loop until all parameters are used up
while [ "$1" != "" ]; do
 status=`lsdef $1 -i status | grep status | sed "s/.*status=//"`
 echo "`date "+%m%d %k:%M:%S"` -- status for $1 is $status"
 if [ "$status" == "booted" ]; then
  echo "Known status for $1 is $status"
  shift
 else
  if [ "$status" == "installing" -o "$status" == "booting" ]; then
    echo "`date "+%m%d %k:%M:%S"` -- Known status for $1 is $status"
  else
    echo "`date "+%m%d %k:%M:%S"` -- Unknown status for $1 is $status"
  fi
  sleep 30
 fi
done
