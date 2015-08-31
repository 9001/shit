#!/bin/bash
#
# part of shit-pulse
# Shellscript Icecast Tools for PulseAudio
# BSD-Licensed, 2015-08-31, ed <irc.rizon.net>
# https://github.com/9001/shit
#

function sighook()
{
	echo
	./volume.sh pacat 0 6 100 &
	./volume.sh Deadbeef 100 6 50
	sleep 0.2
	[ "x$1" == "x" ] || kill -9 $1
	echo "Microphone muted, stream volume restored"
	exit 0
}
trap sighook SIGINT

input="$(
	pactl list |\
	grep -A2 '^Source #' |\
	grep 'Name: .*\.analog-stereo$' |\
	awk '{print $NF}' |\
	tail -n 1
)"

./volume.sh Deadbeef 50 4 100 &

[ "x$1" == "x" ] &&
{
	echo "Script launched without arguments, using plain mic"
	pacat -r --latency-msec=1 -d "$input" 2>/dev/null |\
	pacat -p --latency-msec=1 -d djsink &
	killpid=$!
}

[ "x$1" == "x" ] ||
{
	echo "Script launched with arguments, applying reverb filter"
	pacat -r --latency-msec=1 -d "$input" 2>/dev/null |\
	sox -t raw -r 44100 -e signed-integer -L -b 16 -c 2 - -t raw - \
		compand 0.1,0.3 -60,-60,-30,-15,-20,-12,-4,-8,-2,-7 -2 \
		gain -6 \
		equalizer    40  .71q +12 \
		equalizer    80 1.10q  +0 \
		equalizer   240 1.80q  -3 \
		equalizer   500  .71q  +0 \
		equalizer  1000 2.90q  +0 \
		equalizer  4100  .51q  +2.5 \
		equalizer  8500  .71q  +2.0 \
		equalizer 17000  .71q  +6 \
		gain -3 \
		reverb 65 50 100 100 0 -10 \
		gain 9 |
	pacat -p --latency-msec=1 -d djsink &
	killpid=$!
}

for x in {1..10}
do
	./volume.sh pacat 100 && break
	echo 'i won the race'
	sleep 0.1
done
echo "Press ENTER for smooth shutdown"
echo "Press CTRL-C for panic shutdown"
read -u1 -r
echo -n "Fading music back in..."
sighook $killpid
