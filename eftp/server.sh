#!/bin/bash

CLIENT=`nc -l -p 3333 -w 0`

sleep 2

echo "Servidor de EFTP"

echo "(0) Listen"

DATA=`nc -l -p 3333 -w 0`

echo $DATA 

sleep 1

echo "(3) Test & Send"

if [ "$DATA" != "EFTP 1.0 $CLIENT" ]
then
	echo "ERROR 1: BAD HEADER"
	sleep 1
	echo "KO_HEADER" | nc $CLIENT 3333
	exit 1
fi
echo "OK_HEADER"
sleep 1
echo "OK_HEADER" | nc $CLIENT 3333

echo "(4) Listen"

DATA=`nc -l -p 3333 -w 0`

echo $DATA

sleep 1

echo "(7) Test & Send"

if [ "$DATA" != "BOOOM" ]
then 
	echo "ERROR 2 : BAD HANDSHAKE"
	sleep 1
	echo "KO_HANDSHAKE" | nc $CLIENT 3333
	exit 2
fi
sleep 1
echo "OK_HANDSHAKE" | nc $CLIENT 3333

echo "(8) Listen"
DATA=`nc -l -p 3333 -w 0`
FILE_NAME=echo $DATA | cut -d " " -f 2
sleep 1
echo "(12) Test & Store & Send"
if [ "$DATA" != "FILE_NAME $FILE_NAME" ]
then 
	echo "ERROR 3: BAD FILE_NAME"
	sleep 1
	echo "KO_FILE_NAME" | nc $CLIENT 3333
	exit 3
fi
sleep 1
echo "OK_FILE_NAME"| nc $CLIENT 3333

echo "(13) Listen"
DATA=`nc -l -p 3333 -w 0`
echo $DATA

echo "(16) Store & Send"
if [ "$DATA" != "" ]
then 
	echo "ERROR 4: BAD DATA"
	sleep 1
	echo "KO_DATA" | nc $CLIENT 3333
	exit 4
fi

echo $DATA > inbox/$FILE_NAME
sleep 1
echo "OK_DATA" | nc -l -p $CLIENT 3333

echo "FIN"
exit 0
