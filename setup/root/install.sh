#!/bin/bash

# exit script if return code != 0
set -e

# define pacman packages
pacman_packages="base-devel git systemd"

# install required pre-reqs for makepkg
pacman -S --needed $pacman_packages --noconfirm

# call aur install script (arch user repo)
source /root/aur.sh

# cleanup
yes|pacman -Scc
rm -rf /usr/share/locale/*
rm -rf /usr/share/man/*
rm -rf /tmp/*
