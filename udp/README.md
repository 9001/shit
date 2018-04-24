shit-udp v1.0
===============

* Shellscript Icecast Tools for UDP PCM
* BSD-Licensed, 2017-12-29, ed @ irc.rizon.net
* https://github.com/9001/shit



Supported media players
=======================

* DeaDBeeF (with tags)
* anything that throws PCM out on UDP

get tags from other players by editing `meta.sh`  



Dependencies
============

* the deadbeef developer headers
* probably more (todo)



Compiling DeaDBeeF
==================

(you need the headers to compile the plugin)

* ./configure --prefix=$HOME/pe/deadbeef
* make -j4
* make install



Compiling + installing ddb_udpcast
==================================

* cd ddb_udpcast
* make



First-time setup
================

* edit `yourConfigFile` with stream details (user/pass)
* start deadbeef:
```
LD_LIBRARY_PATH=$HOME/pe/deadbeef/lib/ $HOME/pe/deadbeef/bin/deadbeef
```

* recommended deadbeef config:
```
Edit -> Preferences -> GUI/Misc
    [ ] Enable Russian CP1251 detection and recoding

Edit -> Preferences -> DSP
    Mono to stereo
    Resampler (Secret Rabbit Code)
    SuperEQ
    UDP Unicast

Mono to stereo config:
    Both sliders to max

Resampler config:
    Automatic samplerate: NO
    Target samplerate: 44100
    Quality/Algorithm: SINC_BEST_QUALITY

SuperEQ:
    Default (all flat)
    (don't remember why I added this)

UDP Unicast:
    Host: 127.0.0.1
    Port: 1479
```



Starting your stream
====================

* play some music in deadbeef
* open a terminal and `./stream.sh yourConfigFile`
* mute deadbeef since you should now be hearing the audio twice
