#!/bin/bash

SERVER="locahost"
IP=`ip address | grep inet | grep enp0s3 | cut -d " " -f 6 | cut -d "/" -f 1`

echo $IP

echo "Cliente de EFTP"

echo "(1) Send"

echo "EFTP 1.0" | nc $SERVER 3333

echo "(2) Listen"

DATA=`nc -l -p 3333 -w 0`

echo "(5) Test & Send"

if [ "$DATA" != "OK_HEADER" ]
then 
	echo "ERROR 1: BAD HEADER"
	exit 1
fi
echo "OK_HEADER"
sleep 1


echo "BOOOM" | nc $SERVER 3333

echo "(6) Listen"
DATA=`nc -l -p 3333 -w 0`
