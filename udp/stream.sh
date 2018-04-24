#!/bin/bash
#
# shit-udp v1.1
# Shellscript Icecast Tools for UDP PCM
# BSD-Licensed, 2017-12-29, ed <irc.rizon.net>
# https://github.com/9001/shit
#
#
# INSTALL GUIDE
# =============
#
#   todo, see readme for now
#

which ezstream

[ $# -lt 1 ] && {
	echo "Usage: ./stream yourConfigFile"
	exit 1
}
function cleanup()
{
	ps ax |
	grep -E '(cat -l -u -p 1479$|bash \./metaman.sh$)' |
	awk '{print $1}' |
	while read x
	do
		kill -9 "$x"
	done
}
function sighook()
{
	cleanup
	exit 0
}
trap sighook SIGINT

# the mp3 bitrate we'll stream at,
# extracted from the ezstream config file
bitrage=$(
	cat "$1" |
	grep 'svrinfobitrate' |
	sed 's/.*>\(.*\)<.*/\1/'
)

# filename to dump a copy of our stream to
fn=$(date +%Y-%m-%d_%H-%M-%S)

# start the tag monitor
./metaman.sh >/dev/null &
chmod 644 "$1"

# debug output
echo
echo -e "\033[1;32mStarting stream at $bitrage kbps..."
echo -e "\033[1;32m  dump: \033[0m$fn"
echo

# compose stream feed
{
	# the wav header
	cat head
	
	# the PCM stream data from the dj sink
	ncat -l -u -p 1479 |
	
	# this does have a purpose aside from the dank VU meter
	# but hell if I can recall what
	sox -S -t raw -r 44100 -e signed-integer -Lb 16 -c 2 - -t raw -
} |

# feed to speakers
tee /dev/stderr 2> >(
	
	mkfifo mpv-ctl
	
	mpv --really-quiet --input-file mpv-ctl  -
) |

# encode to MP3
lame --preset cbr $bitrage -q 0 -m j - - |

# save to the local copy
tee live-$fn.mp3 |

# stream to radio
stdbuf -oL $(which ezstream) -c "$1" |
grep -vE '^ezstream: Warning: Empty metadata string'

# stream ended, probably a network issue
mpv down.flac

