#!/bin/bash

######################################################################
#                                                                    #
#  See documentation on https://github.com/fape/bullet-time-scripts  #
#                                                                    #
######################################################################

OWNER_CONFIG="/main/settings/ownername"
TRANSFER_SCRIPT="transfer.sh"

QUEUE=""

function dequeue
{
	echo ""
	echo "Stopping..."

	for PID in ${QUEUE}
	do
		kill -INT ${PID}
	done
}

#detect dependencies
command -v gphoto2 >/dev/null 2>&1 || { echo 1>&2 "ERROR: I require gphoto2 but it's not installed."; exit 1; }
command -v jhead   >/dev/null 2>&1 || { echo 1>&2 "ERROR: I require jhead but it's not installed.";   exit 1; }


#register to events
trap "dequeue" INT TERM EXIT

DB=0

while read line
do
	port=`echo ${line} | egrep -o "usb:([0-9])*,([0-9])*"`
	
	#check port
	if [ "$port" ]; 
	then
		camera=`echo ${line} | sed -e "s/\(.*\)\(${port}\)/\1/g" -e "s/^\s\+//g" -e "s/\s\+$//g"`
	
		#check camera name	
		if [ ! -n "${camera}" ];
		then
			echo "WARNING: Unsupported camera on ${port}" 1>&2
			continue
		fi
		 
		user=`gphoto2 --get-config "${OWNER_CONFIG}" --port "${port}" --camera "${camera}" | \
			 sed -ne "s/Current:\(.*\)/\1/p" | sed -e "s/^\s\+//g" -e "s/\s\+$//g" -e "s/\s\+/_/g"`
		#check user name, use generated if no user information
		if [ ! -n "${user}" ];
		then
			user=`tr -dc A-Za-z0-9_ < /dev/urandom | head -c8`
			echo "WARNING: Use generated name: ${user} on ${camera}, ${port}" 1>&2
		fi
		
		echo -e "${user}\t${camera}\t${port}"
		
		#link or file does NOT exist
		if [ ! -e "${user}" ];
		then	
			ln -s ${TRANSFER_SCRIPT} "${user}"
		fi
		
		#send to background
		gphoto2 --capture-tethered --force-overwrite --hook-script "${user}" \
			--camera "${camera}" --port "${port}" --filename "${user}_%04n.%C" &>/dev/null &
		#save pid
		QUEUE="${QUEUE} $!"
		
		let DB=DB+1
	fi
done < <(gphoto2 --auto-detect) 
# avoid subshell http://stackoverflow.com/questions/4667509/problem-accessing-a-global-variable-from-within-a-while-loop

if [ $DB -gt 0 ];
then
	echo "${DB} camera detected"
	echo "Waiting for images...."
	#waiting for children
	wait
else
	echo "ERROR: No camera detected" 1>&2
fi

#unregister events
trap - INT TERM EXIT

