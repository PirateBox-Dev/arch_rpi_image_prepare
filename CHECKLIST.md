# Image Testing Checklist
If you are part of the testing team, this Checklist is for you. Download the image, dump it to SD card, connect your PirateBox to the same network the computer you are testing from is connected to and then go through the checklist step by step to make sure everything is working as it should.

Before going through the checklist, make sure your USB WiFi is attached and is one of the supported types. Also make sure you have a *FAT32* formatted USB thumb drive attached to your RPi.

## Checklist
* [ ] PirateBox' WiFi is available
* [ ] Connection to PirateBox' WiFi could be established
* [ ] SSH connection to PirateBox with the username *alarm* and the password *alarm* could be established
* [ ] Message of the day containing information about *First Steps* is displayed correctly
* [ ] Change the password for the *alarm* user, log out and log back in
* [ ] Enable USB share
* [ ] Set some date and enable Fake-timeservice
* [ ] Enable Kareha Image and Discussion Board
* [ ] Enable UPnP media server (minidlna)
* [ ] It is possible to post to the chat
* [ ] It is possible to upload files
* [ ] It is possible to post to the board
* [ ] Reboot
* [ ] PirateBox' WiFi is available
* [ ] Connection to PirateBox' WiFi could be established
* [ ] Date matches the set date from the Fake-timeservice
