#!/bin/bash

read -p "Victim IP Address? " IP_ADDR
echo "Pinging $IP_ADDR to ensure it is up (takes 10 seconds)."

timeout 10s ping $IP_ADDR | tee ping_results.txt

count=$( grep "bytes from $IP_ADDR" -E ping_results.txt -c )
pid=$$	# get process id of this script

if [ $count -gt 0 ]	# -gt = greater than, -lt less than, -eq equal to
then echo " "; echo "Found host"; echo "Starting a port scan"; echo " "
else echo " ";echo "Did not find the host!"; echo Ending script; kill $pid
fi

rm ping_results.txt

nmap -sV -v -sC -p 1-10000 $IP_ADDR | tee nmap_results.txt

echo "Complete!"

