#!/bin/bash

read -p "Victim IP Address? " IP_ADDR
echo "Pinging $IP_ADDR to ensure it is up (takes 10 seconds)."

timeout 10s ping $IP_ADDR | tee ping_results.txt

count=$( grep "bytes from $IP_ADDR" -E ping_results.txt -c )
pid=$$	# get process id of this script

if [ $count -gt 0 ]	# -gt = greater than, -lt less than, -eq equal to
then
	echo " "
	echo "Found host"
	echo "Starting a port scan"
	echo " "
else 
	echo " "
	echo "Did not find the host!"
       	echo Ending script
	kill $pid
fi

nmap -sV -v -sC -p 1-1000 $IP_ADDR | tee nmap_results.txt

http=$( grep "http" -E nmap_results.txt -c )
https=$( grep "https" -E nmap_results.txt -c )
service=http

# Use http by default
if [ $http -gt 2 ]
then
	service=http
elif [ $https -gt 2 ]
then
	service=https
fi

echo "Abridged results: "
echo $( grep "/tcp " -E nmap_results.txt )
echo $( grep "/udp" -E nmap_results.txt )

if [ $https -gt 2 ] || [ $http -gt 2 ]
then
	webport=$( grep "http" -E nmap_results.txt | sed '2,2!d' | cut -d/ -f1 )	
	echo " "
	# Needs to account for multiple ports
	echo "Found a webserver on port $webport."
	gobuster dir --url $service://$IP_ADDR:$webport/ -x html,php,txt -w common.txt | tee gobuster_results.txt
else
	echo "No webserver found."
fi

echo "cat the text files created for the complete results."
echo "Commands run: "
echo "nmap -sV -v -sC -p 1-1000 $IP_ADDR"
echo "gobuster dir --url http://$IP_ADDR:$webport/ -x html,php,txt -w common.txt"

echo "If you didn't get the results you wanted, try either scanning different ports or using a different wordlist file on the web directory scan."

