#!/bin/bash

TIMEOUT=1
PORT="3333"

echo "Servidor de EFTP"

echo "(0) Listen"

DATA=`nc -l -p $PORT -w $TIMEOUT`

echo $DATA

PREFIX=`echo $DATA | cut -d " " -f 1`
VERSION=`echo $DATA | cut -d " " -f 2`

sleep 1

echo "(3) Test & Send"

if [ "$PREFIX $VERSION" != "EFTP 1.0" ]
then
	echo "ERROR 1: BAD HEADER"
	sleep 1
	echo "KO_HEADER" | nc $CLIENT $PORT
	exit 1
fi
echo "OK_HEADER"
sleep 1

CLIENT=`echo $DATA | cut -d " " -f 3`

if [ "$CLIENT" == "" ] 
then 
	echo "ERROR 1: EMPTY IP"
	exit 1
fi

echo "OK_HEADER" | nc $CLIENT $PORT

echo "(4) Listen"

DATA=`nc -l -p $PORT -w $TIMEOUT`

echo $DATA

sleep 1

echo "(7) Test & Send"

if [ "$DATA" != "BOOOM" ]
then 
	echo "ERROR 2 : BAD HANDSHAKE"
	sleep 1
	echo "KO_HANDSHAKE" | nc $CLIENT $PORT
	exit 2
fi
sleep 1
echo "OK_HANDSHAKE" | nc $CLIENT $PORT

echo "(7a) Listen"

DATA=`nc -l -p $PORT -w $TIMEOUT`
echo $DATA

echo "(7b) Test & Send"

PREFIX=`echo $DATA | cut -d " " -f 1`

if [ "NUM_FILES" != "$PREFIX" ]
then
	echo "BAD NUM_FILES PREFIX: ERROR 2"
	echo "KO_FILE_NUM" | nc $CLIENT $PORT
	exit 2
fi

echo "OK_FILE_NUM" | nc $CLIENT $PORT

FILE_NUM=`echo $DATA | cut -d " " -f 2`

echo "(8a) Loop" 

for N in `seq $FILE_NUM` 
do

echo "(8b) Listen"

DATA=`nc -l -p $PORT -w $TIMEOUT` 
echo $DATA

PREFIX=`echo "$DATA" | cut -d " " -f 1`
echo $PREFIX

echo "(12) Test & Store & Send"
if [ "$PREFIX" != "FILE_NAME" ]
then 
	echo "ERROR 3: BAD FILE_NAME"
	sleep 1
	echo "KO_FILE_NAME" | nc $CLIENT $PORT
	exit 3
fi
sleep 1
echo "OK_FILE_NAME"| nc $CLIENT $PORT

FILE_NAME=`echo $DATA | cut -d " " -f 2`
FILE_MD5=`echo $DATA | cut -d " " -f 3`
FILE_MD5_LOCAL=`echo $FILE_NAME | md5sum | cut -d " " -f 1`

if [ "$FILE_MD5" != "$FILE_MD5_LOCAL" ]
then 
	echo "ERROR 3: BAD FILE NAME MD5"
	sleep 1
	echo "KO_FILE_NAME" | nc $CLIENT $PORT
	exit 3
fi
echo "OK_FILE_MD5" | nc $CLIENT $PORT

echo "(13) Listen"

nc -l -p $PORT -w $TIMEOUT > inbox/$FILE_NAME
DATA=`cat inbox/$FILE_NAME`
echo $DATA

echo "(16) Test & Store & Send"

if [ "$DATA" == "" ]
then 
	echo "ERROR 4: BAD DATA"
	sleep 1
	echo "KO_DATA" | nc $CLIENT $PORT
	exit 4
fi

sleep 1

echo "OK_DATA" | nc $CLIENT $PORT

echo "(17) Listen"

DATA=`nc -l -p $PORT -w $TIMEOUT`
echo $DATA
FILE_MD5_NAME=`echo $DATA | cut -d " " -f 1`

echo "(20) Test & Send"

if [ "FILE_MD5" != "$FILE_MD5_NAME" ]
then 
	echo "ERROR 5: BAD FILE_MD5"
	sleep 1
	echo "KO_FILE_MD5" | nc $CLIENT $PORT
	exit 5
fi

FILE_MD5_HASH=`echo $DATA | cut -d " " -f 2`
FILE_HASH=`cat inbox/$FILE_NAME | md5sum | cut -d " " -f 1`

if [ "$FILE_MD5_HASH" != "$FILE_HASH" ]
then 
	echo "ERROR 5: BAD FILE_HASH"
	sleep 1
	echo "KO_FILE_HASH" | nc $CLIENT $PORT
	exit 5
fi
echo "OK_FILE_MD5" | nc $CLIENT $PORT

done

echo "FIN"
exit 0
