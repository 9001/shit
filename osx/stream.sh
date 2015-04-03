#!/bin/bash
[ "x$1" == "x" ] &&
{
	echo "Usage: ./stream ezconfig"
	exit 1
}

fn="live-$(date +%Y-%m-%d_%H-%M-%S).mp3"
bitrage=$(cat "$1" | grep 'svrinfobitrate' | sed 's/.*>\(.*\)<.*/\1/')
echo -e "\033[1;33mStreaming at \033[1;37m$bitrage kbit/s\033[1;33m and saving to \033[1;37m$fn\033[0m"

(
	# echo a valid .wav header for lame
	echo 'UklGRiTw/39XQVZFZm10IBAAAAABAAIARKwAABCxAgAEABAAZGF0YQDw/38=' | base64 -D
	
	# record pre-muxed stream data from soundflower
	sox -t coreaudio "Soundflower (2ch)" -t raw -r 44100 -Lb 16 -c 2 -
) |
lame --preset cbr $bitrage -q 0 -m j - - |
tee "$fn" |
ezstream -c "$1"
play -n synth 0.1 pluck A#4 repeat 2
