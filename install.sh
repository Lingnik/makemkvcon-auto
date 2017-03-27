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
. ${ORIGIN}/${SETTINGS_NAME}

echo "-Creating the scripts folder symlink in: ${SCRIPTS_PATH}"
cmd="rm -rf ${SCRIPTS_PATH}" && echo "  $cmd" && $cmd
cmd="ln -sf ${ORIGIN} ${SCRIPTS_PATH}" && echo "  $cmd" && $cmd

echo "-Creating the udev symlink at: ${UDEV_PATH}/${UDEV_NAME}"
cmd="rm -rf ${UDEV_PATH}/${UDEV_NAME}" && echo "  $cmd" && $cmd
cmd="ln -sf ${ORIGIN}/${UDEV_NAME} ${UDEV_PATH}/${UDEV_NAME}" && echo "  $cmd" && $cmd

echo "-Reloading udev rules."
cmd="udevadm control --reload-rules" && echo "  $cmd" && $cmd
cmd="udevadm trigger" && echo "  $cmd" && $cmd

cd "$ORIGINAL_PWD"
echo "Done."
