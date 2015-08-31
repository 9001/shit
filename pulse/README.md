# shit-pulse v1.1

* Shellscript Icecast Tools for PulseAudio
* BSD-Licensed, 2015-08-31, ed <irc.rizon.net>
* https://github.com/9001/shit

### use it like this:
    ./stream.sh yourConfigFile

***************
### ingredients

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
