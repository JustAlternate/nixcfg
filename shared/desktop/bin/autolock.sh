#!/usr/bin/env bash

YubikyConnected=$(lsusb | grep 1050:0407)
if [ -z "$YubikyConnected" ]; then
	swaylock
fi


