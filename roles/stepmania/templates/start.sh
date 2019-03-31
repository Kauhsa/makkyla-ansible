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

{% if piuio_bind_fix %}
# HAX: make sure PIUIO is bound on correct keymap index
piuio_index=0
IFS="
"
# ls -f is important - stepmania iterates devices on same order
for device in $(ls -f /sys/class/input | grep input); do
  device_name=$(cat "/sys/class/input/$device/name")

  # is it the lovely piuio? could it be?
  if [[ $device_name == *"PIUIO"* ]]; then
    echo "PIUIO found in index ${piuio_index}"
    sed "s/JoyXX/Joy1${piuio_index}/g" /home/stepmania/Keymaps.template.ini > /home/stepmania/.stepmania-5.0/Save/Keymaps.ini
    break
  fi

  # fine, it is another joystick? means that PIUIO is bumped one index further
  if ls /sys/class/input/$device/js*; then
    piuio_index=$((piuio_index + 1))
  fi
done
{% endif %}

pasuspender /stepmania/stepmania

if [[ $? -ne 0 ]]; then
  # wait until enter is pressed
  read -p "Press enter to continue"
fi
