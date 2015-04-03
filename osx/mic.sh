#!/bin/bash

# EVENT ---------------------------- #
# Set trap for shutting down cleanly #
# ---------------------------------- #
trap ctrl_c SIGINT
function ctrl_c()
{
	# SHUTDOWN ---------------- #
	# Start fading in the music #
	# ------------------------- #
	{
		echo -e "\n\033[1;33mMusic fading in...\033[0m"
		osascript \
			-e 'tell application "itunes" to repeat with i from 20 to 100 by 1' \
			-e 'set the sound volume to i' \
			-e 'delay 0.01' \
			-e 'end repeat'

		echo -e "\n\033[1;32mMusic 100%\033[0m"
	} &

	# SHUTDOWN ---------------- #
	# Kill the microphone relay #
	# ------------------------- #
	sleep 0.7
	kill -9 $(
		ps ax |
		grep -E '[ ]sox -d -t coreaudio djsink' |
		sed 's/^ *//;s/ .*//'
	)
	echo -e "\n\033[1;33mMicrophone off\033[0m"
	
	wait
	exit 0
}

# STARTUP ---------- #
# Fade out the music #
# ------------------ #
{
	echo -e "\033[1;33mMusic fading out...\033[0m"
	osascript \
		-e 'tell application "itunes" to repeat with i from (sound volume) to 20 by -2' \
		-e 'set the sound volume to i' \
		-e 'delay 0.01' \
		-e 'end repeat'
	echo -e "\n\033[1;33mMusic at 20%\033[0m"
} &

# STARTUP --------------- #
# Enable microphone relay #
# ----------------------- #
{
	echo -e "\033[1;31mMicrophone ON AIR\033[0m"
	sox -d -t coreaudio "djsink" \
		compand 0.1,0.3 -60,-60,-30,-15,-20,-12,-4,-8,-2,-7 -2 \
		gain -3 \
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
		gain 9
} &
echo -e '\033[1;34mPress ENTER to stop microphone cleanly\033[0m'
read -u 1 -n 1 -r
ctrl_c

# pv --width 80 mbp-mic-test-cut.wav |
# tail -c +31 |
# play -t raw -r 44100 -Lb 16 -c 2 -e signed-integer - -c 1 \

