#!/usr/bin/bash -
# based on: https://gist.github.com/tacofumi/3041eac2f59da7a775c6

# The # of chars in the DRV string (`makemkvcon -r info | grep "DRV:0\+"`) until the title
# e.g. 49 for: DRV:0,2,999,12,"BD-RE PLDS BD-RE DH-8B2SH SD11","THIS_IS_YOUR_TITLE_NAME","/dev/sr0"
TITLE_LEN=49
# The folder containing the 'scripts', 'tmp', and 'movies' folders, e.g. /opt/plex
ROOT_PATH=/opt/plex
# A temporary place where makemkvcon can output (possibly-)improperly titled mkvs.
TEMP_PATH=${ROOT_PATH}/tmp
# The final resting place for mkvs.
OUT_PATH=${ROOT_PATH}/movies
# The name of the scripts folder
SCRIPTS_PATH=${ROOT_PATH}/scripts
# The log file name.
LOG_PATH=${TEMP_PATH}/makemkvcon-auto.log
# The path to the udev rules.d folder
UDEV_PATH=/etc/udev/rules.d
# The name of the udev file
UDEV_NAME=99-makemkvcon-auto.rules
# The lock file used to see if this script is running
LOCK_FILE=${TEMP_PATH}/lock
# The trigger file used to let this script continue
TRIGGER_FILE=${TEMP_PATH}/trigger
# The Slack webhook
SLACK_HOOK="https://hooks.slack.com/services/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"
# The room to send log messages to in Slack
LOG_ROOM=makemkv
# The room to send announcement messages to in Slack
ANNOUNCE_ROOM=makemkv

# Abort if the trigger file isn't found.
[[ ! -f ${TRIGGER_FILE} ]] && exit 0
trigger=`cat ${TRIGGER_FILE}`
rm ${TRIGGER_FILE} 

function log {
  msg=$*
  msg="${msg//\"/\\\"}"
  logger "makemkvcon-auto: $msg"
  curl -X POST --data-urlencode "payload={\"channel\": \"#makemkv\", \"text\": \"${msg}\"}" $SLACK_HOOK
  #" Syntax highlighting gone wild.
}

function log_raw {
  outout=$*
  log $'```\n'"${output}"$'\n```'
}

function notify {
  msg=$*
  logger "makemkvcon-auto: $msg"
  curl -X POST --data-urlencode "payload={\"icon_emoji\": \":robot_face:\", \"username\": \"puck\", \"channel\": \"#makemkv\", \"text\": \"${msg}\"}" $SLACK_HOOK
  #" Syntax highlighting gone wild.
}

# Abort if the lock file is found. 
if [[ -f ${LOCK_FILE} ]]; then
  log "Trigger and lock file exists, skipping."
  log_raw "`ps -aef | grep makemkv | grep -v grep`"
  exit 0
fi
touch ${LOCK_FILE}

killall makemkvcon
rm -f ${TEMP_PATH}/old/*.mkv
mv ${TEMP_PATH}/*.mkv ${TEMP_PATH}/old/

log "*LOADED: ${trigger}*"
log "Running as "'`'"$(whoami)"'`'
notify "Someone fed me a disc labeled: ${trigger}. :yum:"

title=$(makemkvcon -r info)
title=`echo "$title" | grep "DRV:0\+"`
log "Disc info: "$'`'"${title}"$'`'
#title=${title:49}
#len=${#title}-12
#title=${title:0:$len}
title=${trigger}
if [[ -z "$title" ]]; then
  log "*ERROR:* Couldn't set the title - No disc found"
  rm ${LOCK_FILE}
  exit 1
fi
log "Using title: $title"

log "Converting to mkv..."
output=`sudo makemkvcon --minlength=4800 --robot --decrypt --directio=true mkv dev:/dev/sr0 0 ${TEMP_PATH}/ 2>&1`
if [[ ! $? -eq 0 ]]; then
  log_raw "${output}"
  notify "I had a problem eating $title -- sorry!"
  rm ${LOCK_FILE}
  exit 1
fi

mv "${TEMP_PATH}/"*.mkv "${TEMP_PATH}/"$title.mkv
if [[ ! -f "${TEMP_PATH}"/$title.mkv ]]; then
  log "*FAILED:* Title was not exported."
  notify "I had a problem eating $title -- sorry!"
  rm ${LOCK_FILE}
  exit 1
fi
mv "${TEMP_PATH}/"$title.mkv "${OUT_PATH}/"

eject
log "Created: ${OUT_PATH}/$title.mkv"
notify "$title will be available on Plex shortly. I am ready to eat another disc. :dancing-penguin:"

log "*Done.*"
rm ${LOCK_FILE}
