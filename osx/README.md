Supported media players
=======================

* iTunes (with tags)
* Literally every other player (without tags)

If you want to use DankTunesLite and you want your tags then edit meta.sh



Dependencies
============

* brew cask install soundflower audiomate
* brew install sox



First-time setup
================

See the attached screenshot for reference

And just for the record, the soundflowerbed config should have both the 2ch and 64ch devices set to their default "None (OFF)" unless you want fun things to happen

* Launch "Audio MIDI Setup"    (type MID into launchpad)
* Create "Multi-Output Device" (click [+] at the bottom right)
* Give it the name "djsink"    (click the name of the device)
* Add the device "Built-In Output"
* Add the device "Soundflower (2ch)"
* Master Device: "Built-In Output"
* Sample-Rate: "44100,0 Hz"
* [YES] Drift Correction for "Soundflower (2ch)"
* [NO] Drift Correction for "Built-In Output"



Starting your stream
====================

* Launch "Audio MIDI Setup"
* Leftclick "djsink"
* Then rightclick it
* "Use this device for sound output"
* Open a terminal and ./stream.sh yourConfigFile
* Open a terminal and ./watch.sh



Your microphone on the air
==========================

* Open a terminal and ./mic.sh
* Press ENTER to mute it again

This fades down the music volume to 20% and slides it back up when disengaging



Adjusting your volume
=====================

* Launch "AudioMate", your new volume control
* Click the 44.1kHz menubar item
* Drag the "Built-In Output" slider

I'm sorry that CoreAudio sucks
