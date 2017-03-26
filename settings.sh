# The # of chars in the DRV string (`makemkvcon -r info | grep "DRV:0\+"`) until the title
# e.g. 49 for: DRV:0,2,999,12,"BD-RE PLDS BD-RE DH-8B2SH SD11","THIS_IS_YOUR_TITLE_NAME","/dev/sr0"
export TITLE_LEN=49
# The folder containing the 'scripts', 'tmp', and 'movies' folders, e.g. /opt/plex
export ROOT_PATH=/opt/plex
# A temporary place where makemkvcon can output (possibly-)improperly titled mkvs.
export TEMP_PATH=${ROOT_PATH}/tmp
# The final resting place for mkvs.
export OUT_PATH=${ROOT_PATH}/movies
# The name of the scripts folder
export SCRIPTS_PATH=${ROOT_PATH}/scripts
# The log file name.
export LOG_PATH=${TEMP_PATH}/makemkvcon-auto.log
# The path to the udev rules.d folder
export UDEV_PATH=/etc/udev/rules.d
# The name of the udev file
export UDEV_NAME=99-makemkvcon-auto.rule
