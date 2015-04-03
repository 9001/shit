#!/bin/bash
while true
do
	sum="$(
		osascript -e 'tell application "iTunes" to artist of current track & "//" & size of current track & "//" & name of current track' | md5
	)"
	[ "x$sum" == "x$osum" ] ||
	{
		killall -USR2 ezstream
		osum="$sum"
	}
	sleep 3
done
