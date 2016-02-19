#!/bin/bash

# exit script if return code != 0
set -e

# call aur packer script
source /root/packer.sh

# cleanup
yes|pacman -Scc
rm -rf /usr/share/locale/*
rm -rf /usr/share/man/*
rm -rf /tmp/*
