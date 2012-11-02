#!/bin/bash

self=`basename $0 .sh`
log=trasfer.log

function logger
{
	d=`date +%m%d-%H%M%S.%N`
	echo $@
	echo -e "${d}\t${self}\t$@" >> $log
}

case "$ACTION" in
	init)
		logger "INIT"
		# exit 1 # non-null exit to make gphoto2 call fail
	;;
	start)
		logger "START"
	;;
	download)
		logger "DOWNLOADING ${ARGUMENT}"
		d=`date +%m%d-%H%M%S.%N`
		name="${d}_${self}.jpg"
		mv $ARGUMENT $name
		logger "DOWLOADED ${ARGUMENT} to ${name}"
	;;
	stop)
		logger "STOP"
	;;
	*)
		logger "UNKNOWN ACTION: $ACTION"
	;;
esac
exit 0
