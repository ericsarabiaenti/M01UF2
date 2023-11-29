#!/bin/bash


TIMEOUT=1

echo "Servidor de EFTP"

echo "(0) Listen"

CLIENT=`nc -l -p 3333 -w $TIMEOUT`
DATA=`nc -l -p 3333 -w $TIMEOUT`

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

DATA=`nc -l -p 3333 -w $TIMEOUT`

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

DATA=`nc -l -p 3333 -w $TIMEOUT` 
echo $DATA

PREFIX=`echo "$DATA" | cut -d " " -f 1`
echo "$PREFIX"

echo "(12) Test & Store & Send"
if [ "$PREFIX" != "FILE_NAME" ]
then 
	echo "ERROR 3: BAD FILE_NAME"
	sleep 1
	echo "KO_FILE_NAME" | nc $CLIENT 3333
	exit 3
fi
sleep 1
echo "OK_FILE_NAME"| nc $CLIENT 3333

FILE_NAME=`echo $DATA | cut -d " " -f 2`
FILE_MD5=`echo $DATA | cut -d " " -f 3`
FILE_MD5_LOCAL=`echo $FILE_NAME | md5sum | cut -d " " -f 1`

if [ "$FILE_MD5" != "$FILE_MD5_LOCAL" ]
then 
	echo "ERROR 3: BAD FILE NAME MD5"
	sleep 1
	echo "KO_FILE_NAME" | nc $CLIENT 3333
	exit 3
fi
echo "OK_FILE_MD5" | nc $CLIENT 3333

echo "(13) Listen"

nc -l -p 3333 -w $TIMEOUT > inbox/$FILE_NAME
DATA=`cat inbox/fary1.txt`
echo $DATA

echo "(16) Test & Store & Send"

if [ "$DATA" == "" ]
then 
	echo "ERROR 4: BAD DATA"
	sleep 1
	echo "KO_DATA" | nc $CLIENT 3333
	exit 4
fi

sleep 1

echo "OK_DATA" | nc $CLIENT 3333

echo "(17) Listen"

DATA=`nc -l -p 3333 -w $TIMEOUT`
echo $DATA
FILE_MD5_NAME=`echo $DATA | cut -d " " -f 1`

echo "(20) Test & Send"

if [ "FILE_MD5" != "$FILE_MD5_NAME" ]
then 
	echo "ERROR 5: BAD FILE_MD5"
	sleep 1
	echo "BAD FILE_MD5" | nc $CLIENT 3333
	exit 5
fi
echo "OK_FILE_MD5" | nc $CLIENT 3333

FILE_MD5=`echo $DATA | cut -d " " -f 2`
FILE_HASH=`cat inbox/fary1.txt | md5sum | cut -d " " -f 1`

if [ "$FILE_MD5" != "$FILE_HASH" ]
then 
	echo "ERROR 5: BAD FILE_HASH"
	sleep 1
	echo "BAD FILE_HASH" | nc $CLIENT 3333
	exit 5
fi
echo "OK_FILE_HASH" | nc $CLIENT 3333

echo "FIN"
exit 0
