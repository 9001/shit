shit-pulse v1.1
===============

* Shellscript Icecast Tools for PulseAudio
* BSD-Licensed, 2015-08-31, ed @ irc.rizon.net
* https://github.com/9001/shit



Supported media players
=======================

* DeaDBeeF (with tags)
* Clementine (with tags)
* anything that uses PulseAudio (without tags)

get tags from other players by editing `meta.sh`  
and edit `mic.sh` too if you wanna keep the dope volume fading



Dependencies
============

* `sudo apt-get install sox lame ezstream pavucontrol mpv`
* option 1: http://deadbeef.sourceforge.net/download.html
* option 2: `sudo apt-get install clementine`
* option 3: no tags unless you roll up your sleeves



First-time setup for DeaDBeeF users
===================================

* edit `yourConfigFile` with stream details (user/pass)
* recommended deadbeef config:
```
Edit -> Preferences -> Sound
    Output plugin:  PulseAudio output plugin
    Output device:  (should be disabled)
    [x] Always convert 8 bit audio to 16 bit
    [ ] Always convert 16 bit audio to 24 bit

Edit -> Preferences -> DSP -> Resampler -> Configure
    Target Samplerate:    44100
    Quality / Algorithm:  SINC_BEST_QUALITY

Edit -> Preferences -> GUI/Misc
    [ ] Enable Russian CP1251 detection and recoding
```
<sup>(disable all "detection and recoding" stuff as it'll cock up unicode tags, meaning stuff that isn't english)</sup>



First-time setup for Clementine users
=====================================

* edit `yourConfigFile` with stream details (user/pass)
* turn volume up full blast (why is it 50% by default)
* idk probably more stuff



Starting your stream
====================

See stremdeks.png if confused
* play some music in whatever media player or browser
* open a terminal and `./stream.sh yourConfigFile`
* in the volume control panel that popped up,  
change your media players audio output to `Send_to_Radio` 



Your microphone on the air
==========================

* Open a terminal and `./mic.sh` if you're boring
* Open a terminal and `./mic.sh lol` if you're groovy
* Press ENTER to mute it again

This fades down the music volume to 20% and slides it back up when disengaging

See troubleshooting below if this sounds like shit (heh)



Adjusting your volume
=====================

* Unlike on macs you can do this just like you've always done it  
* just make sure the media player itself is full blast



ingredients
===========

| filename        | purpose                                       |
|-----------------|-----------------------------------------------|
| stream.sh       | Main script, start manually                   |
| mic.sh          | Microphone overlay, start when needed         |
| metaman.sh      | Tag service, started by stream.sh             |
| yourConfigFile  | Provide filename as argument to stream.sh     |
| down.flac       | File that plays if your stream drops          |
| volume.sh       | Sets media player volume, used by mic.sh      |
| meta.sh         | Tag retriever, used by metaman.sh             |
| head            | Wave header so lame stops being a bitch       |



Troubleshooting
===============

### Microphone sounds like a broken robot

Try editing `mic.sh` and replace all four `--latency-msec=1` with `--latency-msec=500`  
on lines 34, 35, 42 and 57. if it helps, try lower numbers to see how low you can go

### Music slows down or jitters when turning mic on/off

Edit `volume.sh` and replace `-gt 2` with `-gt 20` on line 35
