#!/bin/bash
# useful little function to create a countdown timer in bash scripts

countdown() {
  secs=$1
  shift
  msg=$@
  while [ $secs -gt 0 ]
  do
    printf "\r\033[KWaiting %.d seconds $msg" $((secs--))
    sleep 1
  done
  echo
}

# then use it like this
countdown 5 "to send email; ctrl-c to abort."

# send email code would go here
