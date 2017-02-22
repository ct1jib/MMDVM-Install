#! /bin/sh

#####################################################
#                                                   #
#          Upload firmware para MMDVM Due             #
#                                                   #
#####################################################

# if command line is empty use default file name
FILE=$1
if [ -z "$FILE" ]; then
    FILE=MMDVM.ino.arduino_due_x.bin
fi

# Exit if the file does not exist
if [ ! -f "$FILE" ]
then
    echo "Ficheiro $FILE nao existe"
    exit 255
fi

systemctl stop mmdvmhost

sleep 2

stty -F /dev/ttyACM0 speed 1200 cs8 -cstopb -parenb  > /dev/null 2>&1

sleep 2

echo
echo "escrever o novo firmware $FILE no MMDVM"
echo

bossac --port=ttyACM0 --force_usb_port=false --erase --write --verify --boot=1 --reset $FILE

sleep 2

stty -F /dev/ttyACM0 speed 115200 cs8 -cstopb -parenb  > /dev/null 2>&1

VERSION=`strings $FILE | grep 'MMDVM 2016' | cut -d' ' -f2`

# rename the file if it does not already exist
if [ ! -f "$VERSION.$FILE" ]
then
    mv $FILE $VERSION.$FILE
fi

sleep 2

systemctl start mmdvmhost

sleep 2

systemctl status mmdvmhost

