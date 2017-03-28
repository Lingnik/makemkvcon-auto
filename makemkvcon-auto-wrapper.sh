#!/usr/bin/bash -
if [[ -z "${ID_FS_LABEL}" ]]; then
  exit 0
fi
/usr/bin/logger Disc event detected on /dev/sr0 
echo "${ID_FS_LABEL}" > /opt/plex/tmp/trigger
