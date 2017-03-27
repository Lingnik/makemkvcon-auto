#!/bin/bash
# based on: https://gist.github.com/tacofumi/3041eac2f59da7a775c6

ORIGIN=`dirname "$(readlink -f "$0")"`
. ${ORIGIN}/settings.sh

function log {
  msg=$*
  logger "makemkvcon-auto: $msg"
  curl -X POST --data-urlencode "payload={\"channel\": \"#makemkv\", \"text\": \"${msg}\"}" $SLACK_HOOK
  #"
}

function notify {
  msg=$*
  logger "makemkvcon-auto: $msg"
  curl -X POST --data-urlencode "payload={\"icon_emoji\": \":robot_face:\", \"username\": \"puck\", \"channel\": \"#general\", \"text\": \"${msg}\"}" $SLACK_HOOK
  #"
}

log "_Disc event detected on /dev/sr0_"

if [[ -z "${ID_FS_LABEL}" ]]; then
  exit 0
fi

log "*LOADED: ${ID_FS_LABEL}*"
log "Running as "'`'"$(whoami)"'`'
notify "Someone fed me a disc labeled: ${ID_FS_LABEL}. :yum:"

log "Detecting title..."
title=$(makemkvcon -r info)
title=`echo "$title" | grep "DRV:0\+"`
title=${title:49}
len=${#title}-12
title=${title:0:$len}
if [[ -z "$title" ]]; then
  log "*ERROR:* Couldn't set the title - No disc found"
  exit 1
fi
log "Using title: $title"

log "Converting to mkv..."
output=`sudo makemkvcon --minlength=4800 --robot --decrypt --directio=true mkv dev:/dev/sr0 all ${TEMP_PATH}/ 2>&1`
if [[ ! $? -eq 0 ]]; then
  log $'```\n'"${output//\"/\\\"}"$'\n```'
  notify "I had a problem eating $title -- sorry!"
  exit 1
fi

mv "${TEMP_PATH}/"*.mkv "${TEMP_PATH}/"$title.mkv
if [[ ! -f "${TEMP_PATH}"/$title.mkv ]]; then
  log "*FAILED:* Title was not exported."
  notify "I had a problem eating $title -- sorry!"
  exit 1
fi
mv "${TEMP_PATH}/"$title.mkv "${OUT_PATH}/"

eject
log "Created: ${OUT_PATH}/$title.mkv"
notify "$title will be available on Plex shortly. I am ready to eat another disc. :dancing-penguin:"

log "*Done.*"

