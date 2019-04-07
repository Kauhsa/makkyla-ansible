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

# you can dig around with lsusb -t to find which is which.
left_pad_usb_port="{{ left_pad_usb_port }}"
right_pad_usb_port="{{ right_pad_usb_port }}"

current_index="0"
left_pad_index="NOT_FOUND"
right_pad_index="NOT_FOUND"
IFS="
"

# ls -f is important - stepmania iterates devices on same order
for device in $(ls -f /sys/class/input | grep input); do
  device_name=$(cat "/sys/class/input/$device/name")
  real_device_path=$(realpath /sys/class/input/$device)
  device_usb_path=$(realpath $real_device_path/../../.. | sed -E 's|^.*/(.*).{2}$|\1|g')

  if [[ $device_usb_path == $left_pad_usb_port ]] && (ls /sys/class/input/$device/js* >/dev/null 2>&1); then
    echo "Left device found in index ${current_index}"
    left_pad_index=${current_index}
    current_index=$((current_index + 1))
  elif [[ $device_usb_path == $right_pad_usb_port ]] && (ls /sys/class/input/$device/js* >/dev/null 2>&1); then
    echo "Right device found in index ${current_index}"
    right_pad_index=${current_index}
    current_index=$((current_index + 1))
  elif (ls /sys/class/input/$device/js* >/dev/null 2>&1); then
    # fine, it is other joystick that we don't know of? means that our joysticks are bumped down
    echo "Unknown joystick, incrementing index"
    current_index=$((current_index + 1))
  fi
done

if [[ $left_pad_index == "NOT_FOUND" ]] || [[ $right_pad_index == "NOT_FOUND" ]]; then
  echo ""
  echo "WARNING:"
  echo "One or more configured USB ports were missing. Key bindings were not set, so pads might not work correctly."
  read -p "Press enter to start Stepmania anyway"
else
  cp /home/stepmania/Keymaps.template.ini /home/stepmania/.stepmania-5.0/Save/Keymaps.ini
  sed -i "s/JoyLeft/Joy1${left_pad_index}/g" /home/stepmania/.stepmania-5.0/Save/Keymaps.ini
  sed -i "s/JoyRight/Joy1${right_pad_index}/g" /home/stepmania/.stepmania-5.0/Save/Keymaps.ini
fi

pasuspender /stepmania/stepmania

if [[ $? -ne 0 ]]; then
  # wait until enter is pressed
  read -p "Press enter to continue"
fi