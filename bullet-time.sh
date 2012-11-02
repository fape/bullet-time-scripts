#!/bin/bash

OWNER_CONFIG="/main/settings/ownername"
TRANSFER_SCRIPT=transfer.sh

QUEUE=""

function dequeue
{
	for PID in ${QUEUE}
	do
		#echo "kill ${PID}" 
		kill -INT ${PID}
	done
}


trap "dequeue; exit" INT TERM EXIT
while read line
do
	port=`echo ${line} | egrep -o "usb:([0-9])*,([0-9])*"`
	if [ "$port" ]; 
	then
		camera=`echo ${line} | sed -e "s/\(.*\)\(${port}\)/\1/g" -e "s/^\s*//g" -e "s/\s*$//g"` 
		user=`gphoto2 --get-config "${OWNER_CONFIG}" --port "${port}" --camera "${camera}"| sed -ne "s/Current:\(.*\)/\1/p" | sed -e "s/^\s*//g" -e "s/\s*$//g"`
		echo -e "${user}\t${camera}\t${port}"
		
		if [ ! -e "${user}" ];
		then	
			ln -s ${TRANSFER_SCRIPT} "${user}"
		fi
		
		gphoto2 --capture-tethered --force-overwrite --hook-script "${user}" --camera "${camera}"  --port "${port}" &>/dev/null &
		QUEUE="${QUEUE} $!"
	fi
done < <(gphoto2 --auto-detect) # avoid subshell http://stackoverflow.com/questions/4667509/problem-accessing-a-global-variable-from-within-a-while-loop



echo "Waiting for images...."

wait

trap - INT TERM EXIT

