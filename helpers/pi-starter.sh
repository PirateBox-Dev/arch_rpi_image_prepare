#!/bin/sh
# Try to setup WiFi and if it succeeds, start the PirateBox
/bin/sh -c /opt/piratebox/bin/detect-wifi.sh && /usr/bin/systemctl start piratebox
