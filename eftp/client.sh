#!/bin/bash

SERVER="locahost"
IP=`ip address | grep inet | grep enp0s3 | cut -d " " -f 6 | cut -d "/" -f 1`

echo $IP

echo "Cliente de EFTP"

echo "(1) Send"

echo "EFTP 1.0" | nc $SERVER 3333

echo "(2) Listen"

DATA=`nc -l -p 3333 -w 0`
echo $DATA

sleep 1

echo "(5) Test & Send"

if [ "$DATA" != "OK_HEADER" ]
then 
	echo "ERROR 1: BAD HEADER"
	exit 1
fi

echo "BOOOM"
sleep 1 
echo "BOOOM" | nc $SERVER 3333

echo "(6) Listen"
DATA=`nc -l -p 3333 -w 0`
echo $DATA

sleep 1

echo "(9) Test"

if [ "$DATA" != "OK_HANDSHAKE" ]
then
	echo "ERROR 2: BAD HANDSHAKE"
	sleep 1
	echo "KO_HANDSHAKE" | nc $SERVER 3333
	exit 2
fi
sleep 1

echo "(10) Send" 
echo "FILE_NAME fary1.txt" | nc $SERVER 3333

echo "(11) Listen"
DATA=`nc -l -p 3333 -w 0`
echo $DATA

sleep 1

echo "(14) Test & Send" 
if [ "$DATA" != "OK_FILE_NAME" ]
then 
	echo "ERROR 3: BAD FILE_NAME"
	sleep 1
	echo "KO_FILE_NAME" | nc $SERVER 3333
	exit 3
fi 
sleep 1
echo "cat /home/enti/M01UF2/eftp/imgs/fary1.txt" | nc $SERVER 3333
echo "(15) Listen"
DATA=`nc -l -p 3333 -w 0`
echo $DATA
