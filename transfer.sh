#!/bin/bash

self=`basename $0 .sh`
log=transfer.log
TMPDIR="/tmp/bullet-time-script"
PIPE="$TMPDIR/bullet_pipe"
SHOOT_ID="$TMPDIR/bullet_shoot_id"
DIR="images"

function logger
{
	d=`date +%m.%d-%H:%M:%S.%N`
	echo -e "${d}\t${self}\t$@" >> $log
}

case "$ACTION" in
	init)
		logger "INIT"
	;;
	start)
		logger "START"
	;;
	download)
		id=`date +%s%N`
		shoot=`cat "${SHOOT_ID}"`
		name=`jhead -nf"${DIR}/${shoot}-${id}-%m%d-%H%M%S-${self}" ${ARGUMENT} | grep -ioE "([0-9a-z_-]*)\.jpg$"`
		echo "${name}" > $PIPE 
		logger "DOWLOADED: ${name} (${ARGUMENT})"
	;;
	stop)
		logger "STOP"
	;;
	*)
		logger "UNKNOWN ACTION: $ACTION"
	;;
esac
exit 0
