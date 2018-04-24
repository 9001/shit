#!/bin/bash
#
# part of shit-pulse
# Shellscript Icecast Tools for PulseAudio
# BSD-Licensed, 2015-08-31, ed <irc.rizon.net>
# https://github.com/9001/shit
#

while [ true ]
do
	if [ $# -eq 1 ]; then
		a=$(./metansf.sh artist)
		b=$(./metansf.sh title)
	else
		a=$(./meta.sh artist)
		b=$(./meta.sh title)
	fi
	if [ "${a}" != "${oa}" ] || [ "${b}" != "${ob}" ]
	then
		oa=$a
		ob=$b
		killall -USR2 ezstream
	fi
	sleep 5
done
