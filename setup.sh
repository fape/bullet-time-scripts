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
GETTIME="/main/settings/datetime"
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

	INPUT=`LANG=EN gphoto2 --port $PORT $GET $CONFIGNAME` 
	DATAS=`echo "${INPUT}" | grep "Choice" | sed "s/Choice: \([0-9]\)\+ \(\([a-zA-Z0-9\/]\)\+\)/\2/g" | tr "\\n" ";"; echo "${EXTMSG}" `
	CURRENT=`echo "${INPUT}" | grep "Current"`
	OPTIONLENGHT=`echo "${DATAS}" | grep -o ";" | wc -l`

	echo "Choose ${DISPLAYNAME}:"
	echo "${CURRENT}"


	PS3="Type a number: "
	OIFS=$IFS # save default value
	IFS=";"

	select value in ${DATAS}; do
        	if [ -n "${value}" ]; then
			if [ $REPLY -le $OPTIONLENGHT ]; then
	                	echo "${value} selected"
				((REPLY--))	
				LANG=C gphoto2 --port $PORT $SET $CONFIGNAME="$REPLY"
			fi
			echo -e "\n====================================================================="
		fi
		break
	done

	IFS=$OIFS
}

function set_camera_ownername()
{
        CONFIGNAME=$1
	DISPLAYNAME=$2

	INPUT=`LANG=C gphoto2 --port $PORT $GET $CONFIGNAME`
	CURRENT=`echo "${INPUT}" | grep "Current"`
	
	echo "Choose ${DISPLAYNAME}:"
	echo "${CURRENT}"
	echo "Enter the desired ownername(enter 0 to skip):"
	read NAME
	if [ $NAME != "0" ]; then
	LANG=C gphoto2 --port $PORT $SET $OWNERNAME="$NAME"
	
	fi

}

function sync_time()
{
        CONFIGNAME=$1

	INPUT=`LANG=C gphoto2 --port $PORT $GET $CONFIGNAME`
        CURRENT=`echo "${INPUT}" | grep "Printable" | sed "s/Printable://"`
	DATE=`LANG=C date`

        echo "Do you want to synchronise time?"
        echo "Current time on camera:   ${CURRENT}"
	echo "Current time on PC:        ${DATE}"
        echo "Enter \"yes\" to do so"
        read YES
        if [ $YES == "yes" ]; then
        LANG=C gphoto2 --port $PORT $SET $SYNCTIME

        fi

}

function camera_select()
{
	DEVICES=`LANG=C gphoto2 --auto-detect | grep "Canon EOS" | tr "\\n" ";"`
	PS3="Type a number: "
	OIFS=$IFS # save default value
	IFS=";"

	echo "Detected cameras, please select one:"

	select value in ${DEVICES}; do
		if [ -n "${value}" ]; then
               		echo "${value} selected"
	                echo -e "\n====================================================================="

       		        PORT=`echo "${value}" | egrep -o "usb:([0-9])*,([0-9])*"`
			break
        	fi
done
	IFS=$OIFS
}


camera_select
set_camera_config ${IMGFORMAT} "Image format" ${NEXTMSG}
set_camera_config ${ISO} "Iso" ${NEXTMSG} 
set_camera_config ${APERTURE} "Aperture" ${NEXTMSG}
set_camera_config ${SHUTTER_SPEED} "Shutter speed" ${NEXTMSG}
set_camera_config ${WHITEBALANCE} "White balance" ${NEXTMSG}
set_camera_ownername ${OWNERNAME} "Ownername"
sync_time ${GETTIME}
