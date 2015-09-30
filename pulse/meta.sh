#!/bin/bash
#
# part of shit-pulse
# Shellscript Icecast Tools for PulseAudio
# BSD-Licensed, 2015-08-31, ed <irc.rizon.net>
# https://github.com/9001/shit
#

set -o pipefail
user=$(id -un)
arg="$1"

# checks if a media player is running
function have()
{
	pgrep -ou $user "$1" 2>/dev/null
}

# check if there's a supported media player running,
# and store its pid in the var for black magic later
is_db=$(have deadbeef) ||
is_cl=$(have clementine) ||
{
	[ "x$arg" == "xtitle" ] &&
		echo 'media player 404' ||
		echo ''
	
	exit 0
}

# fix corrupted text
function dec()
{
	orig="$(cat)"
	
	# try to decode weeaboo shit
	sjis="$(IFS= echo "$orig" | iconv -t latin1 2>/dev/null | iconv -f sjis 2>/dev/null)"
	
	# decode ok? if yes, keep it
	[ $? -eq 0 ] &&
		IFS= printf -- "${sjis/\\/\\\\}" ||
		IFS= printf -- "${orig/\\/\\\\}"
	
	# for some reason printf goes "write error: Broken pipe" when
	# theres an \n at the end and i really dont want to know why
	echo 2>/dev/null || true
}

# get artist or title (first argument to function)
function get()
{
	# check if we deadbeef
	[ $is_db ] &&
	{
		[ "x$1" == "xartist" ] &&
			type=a ||
			type=t
		
		"/proc/$is_db/exe" --nowplaying %$type 2>/dev/null |
			dec
		
		true
	} ||
	
	# check if we clementine
	[ $is_cl ] &&
	{
		[ "x$1" == "xartist" ] &&
			mask='^artist: ' ||
			mask='^title: '
		
		qdbus org.mpris.clementine /Player \
		org.freedesktop.MediaPlayer.GetMetadata 2>/dev/null |
			grep -E "$mask" |
			head -n 1 |
			sed 's/^[^:]*: //' |
			dec
		
		true
	}
}

#echo "$(date +%s.%N) start $1" >> /dev/shm/meta.log; sleep 1

[ -z "$1" ] && echo "no data" || get "$1"

#echo "$(date +%s.%N) end   $1" >> /dev/shm/meta.log
