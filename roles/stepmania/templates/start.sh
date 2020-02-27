#!/bin/bash

trap 'xset +dpms; xset s on' EXIT

# disable sleeps
xset -dpms 
xset s off

# try to clone displays for streaming – but if it's not possible for some reason, that's fine as well
(
  xrandr --output HDMI-0 --off --output DVI-D-0 --panning 0x0 &&
  xrandr --output HDMI-0 --same-as DVI-D-0 --mode 1280x720 --scale-from 1920x1080 
) || true

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

# TODO: now that stepmania sorts input devices, this could perhaps be much
# simpler.
for device in $(ls /sys/class/input | grep input); do
  device_name=$(cat "/sys/class/input/$device/name")
  real_device_path=$(realpath /sys/class/input/$device)
  device_usb_port=$(realpath $real_device_path/../../../.. | sed -E 's|^.*/(.*)$|\1|g')

  if [[ $device_usb_port == $left_pad_usb_port ]] && (ls /sys/class/input/$device/js* >/dev/null 2>&1); then
    echo "Left device found in index ${current_index}"
    left_pad_index=${current_index}
    current_index=$((current_index + 1))
  elif [[ $device_usb_port == $right_pad_usb_port ]] && (ls /sys/class/input/$device/js* >/dev/null 2>&1); then
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
  cp /home/stepmania/Keymaps.template.ini /home/stepmania/.stepmania-5.1/Save/Keymaps.ini
  sed -i "s/JoyLeft/Joy1${left_pad_index}/g" /home/stepmania/.stepmania-5.1/Save/Keymaps.ini
  sed -i "s/JoyRight/Joy1${right_pad_index}/g" /home/stepmania/.stepmania-5.1/Save/Keymaps.ini
fi

pasuspender /opt/stepmania/stepmania

if [[ $? -ne 0 ]]; then
  # wait until enter is pressed
  read -p "Press enter to continue"
elif grep -q "5b5c513e-7067-4a14-89de-1fa007d93a33" "/home/stepmania/.stepmania-5.1/Logs/info.txt"; then
  # Above is magic string inserted to logs by stepmania theme if "power off" is selected.
  sudo poweroff
fi
