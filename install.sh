#!/bin/bash
# Usage: $ sudo install.sh
ORIGINAL_PWD=$PWD
if [ "$EUID" -ne 0 ]; then
  echo "WARNING: Please run as root, aborting."
  exit
fi
if [ ! -f settings.sh ]; then
  echo "WARNING: Please run from the folder containing settings.sh, aborting."
  exit
fi
ORIGIN=`dirname "$(readlink -f "$0")"`
echo "-This script resides in ${ORIGIN}, using that as ORIGIN."
if [ ! -d "${ORIGIN}" ]; then
  echo "WARNING: ORIGIN is not a directory, aborting."
  exit
fi

echo "Installing makemkvcon-auto scripts."

SETTINGS_NAME=settings.sh
echo "-Reading ${ORIGIN}/${SETTINGS_NAME}"
. "${ORIGIN}"/${SETTINGS_NAME}

echo "-Creating the scripts folder symlink in: ${SCRIPTS_PATH}"
cd ${ROOT_PATH}
ln -fs "${ORIGIN}" ${SCRIPTS_PATH} 

echo "-Creating the udev symlink at: ${UDEV_PATH}/${UDEV_NAME}"
cd ${UDEV_PATH}
ln -fs "${ORIGIN}"/${UDEV_NAME} ${UDEV_NAME}

cd "$ORIGINAL_PWD"
echo "Done."
