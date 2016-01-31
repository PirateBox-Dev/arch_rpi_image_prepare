## Just a short list of TODO's

### For current release

* [ ] Add shout outs for the people involved in testing (waiting for TheExpertNoob)
* [ ] Droopy shows retry after successfull file upload to usb
* [x] minidlna service will not start with the given MOTD text - can not reproduce
* [x] Add instructions about adding a USB drive directly to MOTD
* [x] Add script to help with moving all needed files to USB
* [x] Show disk usage properly when files have been moved to USB

### Maybe later

* [ ] rename hostname to something cool
* [ ] swap the alarm user with something related to PirateBox
* [ ] Add information about raspiconfig and disk resize to MOTD

### Done
Just for reference until they have been noted in a Changelog.

* [x] If a wirlesss card is available but not capable of AP mode, connect to WiFi network provided via /boot/wpa_supplicant.conf
* [x] Update the MOTD to be super extra fancy => in Webserver_scripts repo
* [x] Add a target to compress the resulting image, make sure to stick to the naming conventions
* [x] Automagically regognize if one of the shittier wifi sticks is present and swap hostapd accordingly (also adapt config files accordingly) [related 1](https://bitbucket.org/locative/invisibleislands-devices/src/4d7555e4bf5652a7840805dca9a4e40e1a06c752/raspberrypi-setup.py?fileviewer=file-view-default), [related 2] (https://github.com/LibraryBox-Dev/package-arch-librarybox-config)
