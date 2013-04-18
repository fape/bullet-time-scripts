#!/bin/bash

######################################################################
#                                                                    #
#  See documentation on https://github.com/fape/bullet-time-scripts  #
#                                                                    #
######################################################################

OWNER_CONFIG="/main/settings/ownername"
TRANSFER_SCRIPT="transfer.sh"
TMPDIR="/tmp/bullet-time-script"
PIPE="$TMPDIR/bullet_pipe"
SHOOT_ID="$TMPDIR/bullet_shoot_id"
SHOOT_ID_FORMAT="%03d"
QUEUE_INT=""
QUEUE_TERM=""

function read_console()
{
	while read line
	do
		shoot_id_old=`cat ${SHOOT_ID}`
		shoot_id=`expr ${shoot_id_old} + 1`
		#echo "${shoot_id}" 
		printf "${SHOOT_ID_FORMAT}" "${shoot_id}" > ${SHOOT_ID}
	done
}

function read_pipe()
{
	DB=0
	while [ -p "${PIPE}" ];
	do
		if read line < "${PIPE}";
		then
			let DB=DB+1
			#echo -e "${DB}\tDownloaded:\t${line}"
			echo -e "${DB}\t${line}"
		fi
	done
}

function dequeue
{
	for pid in ${QUEUE_INT}
	do
		kill -INT ${pid} 
	done
	
	for pid in ${QUEUE_TERM}
	do
		kill -TERM ${pid} 
	done
}

function exit_script()
{
	echo ""
	echo "Stopping..."

	dequeue
	
	if [ -p "${PIPE}" ]
	then
		rm -f "${PIPE}"
	fi
	
}

#detect dependencies
command -v gphoto2 >/dev/null 2>&1 || { echo 1>&2 "ERROR: I require gphoto2 but it's not installed."; exit 1; }
command -v jhead   >/dev/null 2>&1 || { echo 1>&2 "ERROR: I require jhead but it's not installed.";   exit 1; }


#register to events
trap "exit_script" INT TERM EXIT

#create bullet time tmp dir
mkdir -p $TMPDIR

#create named pipe for communication if not exists
if [ ! -p "${PIPE}" ];
then
	mkfifo "${PIPE}"
fi

#reset shoot id
printf $SHOOT_ID_FORMAT 0 > ${SHOOT_ID}

DB=0
DATA="Ownername;Camera;Port"

while read line
do
	port=`echo "${line}" | egrep -o "usb:([0-9])*,([0-9])*"`
	
	#check port
	if [ -n "$port" ]; 
	then
		camera=`echo "${line}" | sed -e "s/\(.*\)\(${port}\)/\1/g" -e "s/^\s\+//g" -e "s/\s\+$//g"`
	
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
			user=`echo -n "rn_"; tr -dc A-Za-z0-9_ < /dev/urandom | head -c6`
			echo "WARNING: Use generated name: ${user} on ${camera}, ${port}" 1>&2
		fi
		
		DATA=`echo "${DATA}"; echo "${user};${camera};${port}"`
		
		#link or file does NOT exist
		if [ ! -e "${user}" ];
		then	
			ln -s "${TRANSFER_SCRIPT}" "${user}"
		fi
	
		#start image capture background process 	
		gphoto2 --capture-tethered --force-overwrite --hook-script "${user}" \
			--camera "${camera}" --port "${port}" --filename "${user}_%04n.%C" &>/dev/null &
		#save pid
		QUEUE_INT="${QUEUE_INT} $!"
		
		let DB=DB+1
	fi
done < <( LANG=EN gphoto2 --auto-detect) 
# avoid subshell http://stackoverflow.com/questions/4667509/problem-accessing-a-global-variable-from-within-a-while-loop

if [ ${DB} -gt 0 ];
then
	read_pipe &
	#save pid
	QUEUE_TERM="${QUEUE_TERM} $!"

	# redirect input to background process
	# http://unix.stackexchange.com/questions/71205/background-process-pipe-inputi
	#{ read_console <&3 3<&- & } 3<&0
	read_console <&0 & # BASH ONLY
	QUEUE_TERM="${QUEUE_TERM} $!"

	echo "${DATA}" | column -t -s ";"

	echo "${DB} camera detected."
	echo "Press ENTER to increase shoot/scene id"
	echo "Waiting for images...."
	#waiting for children
	wait
else
	echo "ERROR: No camera detected" 1>&2
fi

#unregister events
trap - INT TERM EXIT

