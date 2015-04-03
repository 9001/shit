#!/bin/bash

key=''
[ "x$1" == "xtitle" ] && key=name
[ "x$1" == "xartist" ] && key=artist

[ $key ] ||
{
	echo 'shellscript icecast tools'
	exit 0
}

# --------------------------- #
# Retrieve value from iTunes, #
# return "warning" if blank   #
# ----------------------------#
{
	osascript -e "tell application \"iTunes\" to if player state is playing then $key of current track" || true
} |
tee /dev/stderr \
2> >(grep -q '.' || echo "Unknown $1")

