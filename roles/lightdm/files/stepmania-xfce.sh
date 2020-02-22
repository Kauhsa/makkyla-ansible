#!/bin/sh

xterm +maximized -e /home/stepmania/start-stepmania.sh

# unfuck displays. I don't really know XFCE is doing.
(sleep 2 && xrandr --output HDMI-0 --off --output DVI-D-0 --panning 0x0) &

startxfce4
