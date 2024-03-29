# Raspberry Pi Kiosk Cooker
##### A bash script to turn a Raspberry Pi into a barebones X Windows kiosk.  

_Tested on a Raspberry Pi 5 running Raspberry Pi OS Lite (64-bit) "Bookworm" released on 2023-12-11_

This is a script I use for the initial set up of a Raspberry Pi as a single or dual-display kiosk-style device.  Typical use cases are status/dashboard displays, automated media players and touch control interfaces (for [Home Assistant](https://www.home-assistant.io/) in my case).  This script _does not_ fully set up the Pi for these cases, but  _does_ take care of the initial set up of a barebones X Windows environment such that running the necessary application(s) should be relatively straight-forward.

## Disclaimer
I use this script for hobby/personal projects in non-critical, controlled environments; there is virtually no thought put into securing/hardening the device or operating system.  Like the associated MIT license says, "THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND", so use it at your own risk! (But I *do* hope you find it useful, as I do!)

## Installation
### The Easy Way
`curl -sS "https://raw.githubusercontent.com/fasteddy516/rpi_kiosk_cooker/main/kiosk_cooker.sh" | sudo bash -s -- --user=<user> --password=<pass>`
