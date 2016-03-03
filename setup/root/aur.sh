#!/bin/bash

# exit script if return code != 0
set -e

# define aur helper
aur_helper="packer"

# define pacman packages
pacman_packages="base-devel systemd jshon git"

# define packer packages
aur_packages="plex-media-server-plexpass"

# install required pre-reqs for makepkg
pacman -S --needed $pacman_packages --noconfirm

# create "makepkg-user" user for makepkg
useradd -m -s /bin/bash makepkg-user
echo -e "makepkg-password\nmakepkg-password" | passwd makepkg-user
echo "makepkg-user ALL=(ALL) NOPASSWD: ALL" | (EDITOR="tee -a" visudo)

# download aur helper
curl -L -o "/usr/bin/$aur_helper" "https://github.com/binhex/arch-patches/raw/master/arch-packer/$aur_packages"
chmod a+x "/usr/bin/$aur_packages"

# install app using aur helper
su -c "$aur_helper -S $aur_packages --noconfirm" - makepkg-user

# remove base devel tools
pacman -Ru base-devel git --noconfirm

# delete makepkg-user account
userdel -r makepkg-user