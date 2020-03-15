#!/bin/sh

xterm +maximized -e /home/stepmania/start-stepmania.sh

# unfuck displays. I don't really know XFCE is doing.
(sleep 2 && xrandr --output HDMI-0 --off --output "{{ main_display_device }}" --panning 0x0) &

startxfce4
