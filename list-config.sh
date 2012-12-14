#!/bin/bash

######################################################################
#                                                                    #
#  See documentation on https://github.com/fape/bullet-time-scripts  #
#                                                                    #
######################################################################

## TODO: move everything into bullet-time.sh

ISO="/main/imgsettings/iso"
APERTURE="/main/capturesettings/aperture"
SHUTTER_SPEED="/main/capturesettings/shutterspeed"
WHITEBALANCE="/main/imgsettings/whitebalance"
SYNCTIME="/main/actions/syncdatetime=1"
TIME="/main/settings/datetime"
IMGFORMAT="/main/imgsettings/imageformat"
OWNERNAME="/main/settings/ownername"
GET="--get-config"

function list_config()
{
        LANG=EN gphoto2 --port "$1" --camera "$2" \
                        $GET $OWNERNAME \
                        $GET $ISO \
                        $GET $APERTURE \
                        $GET $SHUTTER_SPEED \
                        $GET $WHITEBALANCE \
                        $GET $TIME \
                        $GET $IMGFORMAT | grep "Current:" | sed "s/Current: \(.\+\)$/\1/g" | sed "{:q;N;s/\n/;/g;t q}" | \
                                 awk -F ";" '{ print $1 ";" $2 ";" $3 ";" $4 " s;" $5 ";" strftime("%Y.%m.%d %H:%M:%S", $6) ";" $7 }'
        # http://stackoverflow.com/questions/1251999/sed-how-can-i-replace-a-newline-n
}

function print_config_table()
{
        DATA="Owner;ISO;Aperture;Shutter speed;White balance;Time;Image format"

        while read line
        do
                port=`echo ${line} | egrep -o "usb:([0-9])*,([0-9])*"`
                camera=`echo ${line} | sed -e "s/\(.*\)\(${port}\)/\1/g" -e "s/^\s\+//g" -e "s/\s\+$//g"`

                if [ -n "${port}" -a -n "${camera}" ]; then
                        DATA=`echo "$DATA"; list_config "${port}" "${camera}"`
                fi
        done < <( LANG=EN gphoto2 --auto-detect)

        echo "$DATA" | column -t -s ";"
}


print_config_table

