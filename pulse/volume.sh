#!/bin/bash
#
# part of shit-pulse
# Shellscript Icecast Tools for PulseAudio
# BSD-Licensed, 2015-08-31, ed <irc.rizon.net>
# https://github.com/9001/shit
#

# target application
name=$1

# target volume level in percent
level=$2

[ $# -lt 2 ] && {
	echo "Required arguments: APP_NAME, VOLUME_PERCENT"
	echo "Optional extra arguments: STEPS, VOLUME_FROM"
	exit 1
}

# get the stream id to control
sid=$(
	pacmd list-sink-inputs |
	grep "client: [0-9]* <${name}>" -B100 |
	grep 'index: ' |
	tail -n 1 |
	sed 's/[^0-9]*//;s/[^0-9].*//'
)

[ "x$sid" == "x" ] && {
	echo "Could not find application's audio stream"
	exit 1
}

[ $# -gt 2 ] &&
{
	steps=$3
	from=$4
	dist=$(( level - from ))
	step=$(( dist / steps ))
	
	while [ $steps -gt 0 ]
	do
		steps=$(( steps - 1 ))
		from=$(( from + step ))
		pactl set-sink-input-volume ${sid} ${from}%
		sleep 0.1
	done
}
pactl set-sink-input-volume ${sid} ${level}%
