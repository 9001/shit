#!/bin/bash
#
# shit-pulse v1.1
# Shellscript Icecast Tools for PulseAudio
# BSD-Licensed, 2015-08-31, ed <irc.rizon.net>
# https://github.com/9001/shit
#
#
# INSTALL GUIDE
# =============
#
# sudo apt-get install sox lame ezstream pavucontrol mpv
#
# DeaDBeeF: Edit -> Preferences -> Sound
#   Output plugin: PulseAudio output plugin
#   Output device: (should be disabled)
#   [x] Always convert 8 bit audio to 16 bit
#   [ ] Always convert 16 bit audio to 24 bit
#
# DeaDBeeF: Edit -> Preferences -> DSP -> Resampler -> Configure
#   Target Samplerate: 44100
#   Quality / Algorithm: SINC_BEST_QUALITY
#

[ $# -lt 1 ] && {
	echo "Usage: ./stream yourConfigFile"
	exit 1
}
function cleanup()
{
	for x in {1..8}
	do
		i=$(
			pacmd list-modules |
			grep 'source=djsink.monitor' -B50 |
			grep 'index: ' |
			tail -n 1 |
			sed 's/[^0-9]*//;s/[^0-9].*//'
		)
		[ "x$i" == "x" ] && break;
		echo -e "\033[1;32mDestroying loopback $i...\033[0m"
		pactl unload-module $i
	done
	ps ax |
	grep -E 'bash \./metaman.sh$' |
	sed 's/^ *//;s/ .*//' |
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

# the name of the input stream,
# created using module-null-sink and module-loopback
monrec='djsink.monitor'

# the default output sink, we'll select the last if
# there's more than just one... PROBABLY your speakers
monspk=$(
	pactl list |
	grep -A2 '^Source #' |
	grep 'Name: .*\.monitor$' |
	awk '{print $NF}' |
	grep -v "$monrec" |
	tail -n1
)

# the mp3 bitrate we'll stream at,
# extracted from the ezstream config file
bitrage=$(
	cat "$1" |
	grep 'svrinfobitrate' |
	sed 's/.*>\(.*\)<.*/\1/'
)

# filename to dump a copy of our stream to
fn=$(date +%Y-%m-%d_%H-%M-%S)

# set up radio sink if not exist
pactl list short | grep -qE 'Send_to_Radio' ||
{
	echo -ne "\033[1;32mCreating sink 'Send_to_Radio'... \033[0m"
	pactl load-module module-null-sink sink_name=djsink \
		sink_properties=device.description="Send_to_Radio"
}

# open the audio control panel, if closed
ps aux | grep -qE ' pavucontrol$' ||
	pavucontrol >/dev/null 2>/dev/null &

# relay the stream to the speakers
cleanup
echo -ne "\033[1;32mCreating loopback... \033[0m"
pactl load-module module-loopback source="$monrec" sink="$(
	echo "$monspk" | sed 's/\.monitor$//')"

# start the tag monitor
./metaman.sh >/dev/null &
chmod 644 "$1"

# debug output
echo
echo -e "\033[1;32mStarting stream at $bitrage kbps..."
echo -e "\033[1;32m    to: \033[0m$monspk"
echo -e "\033[1;32m  from: \033[0m$monrec"
echo -e "\033[1;32m  dump: \033[0m$fn"
echo

# compose stream feed
{
	# the wav header
	cat head
	
	# the PCM stream data from the dj sink
	parec -d "$monrec" |
	
	# this does have a purpose aside from the dank VU meter
	# but hell if I can recall what
	sox -S -t raw -r 44100 -e signed-integer -Lb 16 -c 2 - -t raw -
} |

# encode to MP3
lame --preset cbr $bitrage -q 0 -m j - - |

# save to the local copy
tee live-$fn.mp3 |

# stream to radio
ezstream -c "$1"

# stream ended, probably a network issue
mpv down.flac
