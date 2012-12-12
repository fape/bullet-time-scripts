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
WHITEBALANCE="/main/imgsettings/whitebalance"
SYNCTIME="/main/actions/syncdatetime=1"
IMGFORMAT="/main/imgsettings/imageformat"
OWNERNAME="/main/settings/ownername"
GET="--get-config"
SET="--set-config"
NEXTMSG="Next"

function set_camera_config()
{
	CONFIGNAME=$1
	DISPLAYNAME=$2
	EXTMSG="Quit"
	if [ -n "$3" ]; then
		EXTMSG=$3
	fi

	INPUT=`LANG=C gphoto2 $GET $CONFIGNAME` 
	DATAS=`echo "${INPUT}" | grep "Choice" | sed "s/Choice: \([0-9]\)\+ \(\([a-zA-Z]\)\+\)/\2/g" | tr "\\n" ";"; echo "${EXTMSG}" `
	CURRENT=`echo "${INPUT}" | grep "Current"`
	OPTIONLENGHT=`echo "${DATAS}" | grep -o ";" | wc -l`

	echo "Choose ${DISPLAYNAME}:"
	echo "${CURRENT}"


	PS3="Type a number: "
	OIFS=$IFS # save default value
	IFS=";"

	select value in ${DATAS}; do
        	if [ -n "${value}" ]; then
                	echo "${value} selected"
			echo -e "\n====================================================================="

			if [ $REPLY -le $OPTIONLENGHT ]; then
			((REPLY--))	
			gphoto2 $SET $CONFIGNAME=$REPLY		
			fi
			break
		fi

	done

	IFS=$OIFS
}

function set_camera_ownername()
{
        CONFIGNAME=$1
        DISPLAYNAME=$2
        EXTMSG="Quit"
        if [ -n "$3" ]; then
                EXTMSG=$3
        fi


	INPUT=`LANG=C gphoto2 $GET $CONFIGNAME`
	CURRENT=`echo "${INPUT}" | grep "Current"`
	
	echo "Choose ${DISPLAYNAME}:"
	echo "${CURRENT}"
	echo "Enter the desired ownername:(enter 0 to skip)"
	read NAME
	if [ $NAME != "0" ]; then
	gphoto2 $SET $OWNERNAME="$NAME"
	
	fi

}


set_camera_config ${IMGFORMAT} "Image format" ${NEXTMSG}
set_camera_config ${ISO} "Iso" ${NEXTMSG}
set_camera_config ${APERTURE} "Aperture" ${NEXTMSG}
set_camera_config ${SHUTTER_SPEED} "Shutter speed" ${NEXTMSG}
set_camera_config ${WHITEBALANCE} "White balance" ${NEXTMSG}
set_camera_ownername ${OWNERNAME} "Ownername" ${NEXTMSG}
