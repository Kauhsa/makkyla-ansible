#!/bin/bash

# run fsr-server
/home/stepmania/Desktop/mckyla-fsr/web-ui/fsrServer.sh &

# make sure pulseaudio is running
pulseaudio --daemonize --start

trap 'pkill unclutter; xset +dpms; xset s on' EXIT

# disable sleeps
xset -dpms 
xset s off

# hide mouse cursor if not moved
unclutter -idle 1 -root &

# try to clone displays for streming – but if it's not possible for some reason, that's fine as well
(
  xrandr --output HDMI-0 --off --output DVI-D-0 --panning 0x0 &&
  xrandr --output HDMI-0 --same-as DVI-D-0 --mode 1280x720 --scale-from 1920x1080 
) || true

# force vsync off
export __GL_SYNC_TO_VBLANK=0

# clear padmiss profile directories
rm -rf /tmp/padmiss-daemon-p1
rm -rf /tmp/padmiss-daemon-p2

pasuspender /stepmania/stepmania

if [[ $? -ne 0 ]]; then
  # wait until enter is pressed
  read -p "Press enter to continue"
fi
