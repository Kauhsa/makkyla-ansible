#!/bin/bash

set -e

# create .deploy-analog-dance-pad-client.rc and set
# contents to something like this:
#
# export ANALOG_DANCE_PAD_CLIENT_PATH=/Users/kauhsa/code/analog-dance-pad/client


source .deploy-analog-dance-pad-client.rc
if [ -z "$ANALOG_DANCE_PAD_CLIENT_PATH" ]; then
  echo "Set ANALOG_DANCE_PAD_CLIENT_PATH environment variable."
  exit 1
fi

export REACT_APP_SERVER_ADDRESSES="192.168.11.40:3333,192.168.11.41:3333,192.168.11.42:3333"
export REACT_APP_FORCE_NONSECURE="true"
export REACT_APP_CALIBRATION_PRESETS="Sensitive:0.1,Normal:0.15,Stiff:0.20"

(
  cd "$ANALOG_DANCE_PAD_CLIENT_PATH" &&
  npm run build &&
  surge build makkyla-padit.surge.sh
)