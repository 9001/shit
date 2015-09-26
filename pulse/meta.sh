#!/bin/bash
#
# part of shit-pulse
# Shellscript Icecast Tools for PulseAudio
# BSD-Licensed, 2015-08-31, ed <irc.rizon.net>
# https://github.com/9001/shit
#
# edit the path below
DEADBEEF='/home/ed/bin/deadbeef/deadbeef'

set -o pipefail
function get()
{
	type='a'
	[ "x$1" == "xt" ] && type=t
	
	# read tag from deadbeef
	orig="$("$DEADBEEF" --nowplaying %$type 2>/dev/null)"
	
	# try to decode weeaboo shit
	sjis="$(IFS= echo "$orig" | iconv -t latin1 2>/dev/null | iconv -f sjis 2>/dev/null)"
	
	# decode ok? if yes, keep it
	[ $? -eq 0 ] &&
		IFS= echo -n "$sjis" ||
		IFS= echo -n "$orig"
}

# broilerplate
[ -z "$1" ] && echo "no data"
[ "x$1" = "xartist" ] && get a
[ "x$1" = "xtitle" ] && get t
