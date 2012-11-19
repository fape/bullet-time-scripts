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
	for PID in ${QUEUE}
	do
		kill -INT ${PID}
	done
}

#register to events
trap "dequeue; exit" INT TERM EXIT

while read line
do
	port=`echo ${line} | egrep -o "usb:([0-9])*,([0-9])*"`
	
	#check port
	if [ "$port" ]; 
	then
		camera=`echo ${line} | sed -e "s/\(.*\)\(${port}\)/\1/g" -e "s/^\s*//g" -e "s/\s*$//g"`
	
		#check camera name	
		if [ "x" == "x${camera}" ];
		then
			echo "Unsupported camera on ${port}" 1>&2
			continue
		fi
		 
		user=`gphoto2 --get-config "${OWNER_CONFIG}" --port "${port}" --camera "${camera}"| sed -ne "s/Current:\(.*\)/\1/p" | sed -e "s/^\s*//g" -e "s/\s*$//g"`
		
		#check user name, use generated if no user information
		if [ "x" == "x${user}" ];
		then
			user=`tr -dc A-Za-z0-9_ < /dev/urandom | head -c8`
			echo "Use generated name: ${user} on ${camera}, ${port}" 1>&2
		fi
		
		echo -e "${user}\t${camera}\t${port}"
		
		#link or file does NOT exist
		if [ ! -e "${user}" ];
		then	
			ln -s ${TRANSFER_SCRIPT} "${user}"
		fi
		
		#send to background
		gphoto2 --capture-tethered --force-overwrite --hook-script "${user}" --camera "${camera}"  --port "${port}" &>/dev/null &
		#save pid
		QUEUE="${QUEUE} $!"
	fi
done < <(gphoto2 --auto-detect) # avoid subshell http://stackoverflow.com/questions/4667509/problem-accessing-a-global-variable-from-within-a-while-loop


echo "Waiting for images...."

#waiting for childens
wait

#unregister events
trap - INT TERM EXIT

