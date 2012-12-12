#!/bin/bash

######################################################################
#                                                                    #
#  See documentation on https://github.com/fape/bullet-time-scripts  #
#                   Make sure to read the setup.readme               #
#                                                                    #
######################################################################

ISO="/main/imgsettings/iso"
APERTURE="/main/capturesettings/aperture"
SHUTTER_SPEED="/main/capturesettings/shutterspeed"
WHITEBALACE="/main/imgsettings/whitebalance"
SYNCTIME="/main/actions/syncdatetime=1"
IMGFORMAT="/main/imgsettings/imageformat"
OWNERNAME="/main/settings/ownername"
GET="--get-config"
SET="--set-config"

OIFS=$IFS # save default value
IFS=";"
PS3="Type a number: "

INPUT=`LANG=C gphoto2 $GET $IMGFORMAT` 
DATA=`echo ${INPUT}| grep "Choice" | sed "s/Choice: \([0-9]\)\+ \(\([a-zA-Z]\)\+\)/\2/g" | tr "\\n" ";"; echo  "Quit" `
CURRENT=`echo ${INPUT} | grep "Current"`
OPTIONLENGHT=`echo "$DATA" | grep -o ";" | wc -l`

echo "Choose Image format:"
echo "$CURRENT"

select value in ${DATA}; do
        if [ -n "${value}" ]; then
                echo "${value} selected"

		if [ $REPLY -le $OPTIONLENGHT ]; then
		((REPLY--))	
		gphoto2 $SET $IMGFORMAT=$REPLY
		
		fi
		break
        fi

done

IFS=$OIFS

