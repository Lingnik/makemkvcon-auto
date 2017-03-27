# makemkvcon-auto
Automatically launch makemkvcon on Linux using udev on disc insert.

# Installation

    sudo ./install.sh


# Troubleshooting

## Show udev parameters for /dev/sr0

    udevadm info --query=all --name=sr0

## Show trace of rules to make sure your rule would run

    udevadm test $(udevadm info -q path -n /dev/sr0) 2>&1

## Eject/uneject the disc

    sudo eject && sudo eject -t

## Monitor udev events

    sudo udevadm monitor

## Force reload of udev rules

    sudo udevadm control --reload-rules && sudo udevadm trigger
