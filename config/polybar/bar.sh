#!/usr/bin/env bash

for mon in $(polybar --list-monitors | cut -d":" -f1); do
	(MONITOR=$mon polybar -q bar1 -c "$HOME"/.config/polybar/config.ini)&
	(MONITOR=$mon polybar -q bar2 -c "$HOME"/.config/polybar/config.ini)&
done