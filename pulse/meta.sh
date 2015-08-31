#!/bin/sh
#
# part of shit-pulse
# Shellscript Icecast Tools for PulseAudio
# BSD-Licensed, 2015-08-31, ed <irc.rizon.net>
# https://github.com/9001/shit
#
# edit the path below
DEADBEEF='/home/ed/bin/deadbeef/deadbeef'

test -z "${1}" && echo "no data"
test x"${1}" = "xartist" && "$DEADBEEF" --nowplaying %a 2>/dev/null
test x"${1}" = "xtitle"  && "$DEADBEEF" --nowplaying %t 2>/dev/null
