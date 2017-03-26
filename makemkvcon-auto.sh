#!/bin/bash
# based on: https://gist.github.com/tacofumi/3041eac2f59da7a775c6

. settings.sh

{
  echo $(date)

  echo ">>>Disk found"
  echo ">>>Setting the title..."

  title=$(makemkvcon -r info)
  title=`echo "$title" | grep "DRV:0\+"`
  title=${title:${TITLE_LEN}}
  len=${#title}-12
  title=${title:0:$len}

  if [[ -z $title ]]; then
    echo ">>>Couldn't set the title - No disk found"
    echo ">>>Exit->"
    exit;
  else
    echo ">>>Title set: $title"
    echo ">>>Starting ripping..."

    makemkvcon --minlength=4800 -r --decrypt --directio=true mkv disc:0 all ${TEMP_PATH}/ > /dev/null

    mv "${TEMP_PATH}/"*.mkv "${TEMP_PATH}/"$title.mkv
    mv "${TEMP_PATH}/"$title.mkv "${OUT_PATH}/"

    eject
    echo ">>>title: $title.mkv created."

fi
} &>> "${TEMP_PATH}/${LOG_NAME}"
