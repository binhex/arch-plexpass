#!/bin/bash

# exit script if return code != 0
set -e

# define pacman packages
pacman_packages="base-devel systemd"

# define packer packages
packer_packages="plex-media-server-plexpass"

# install required pre-reqs for makepkg
pacman -S --needed $pacman_packages --noconfirm

# create "makepkg-user" user for makepkg
useradd -m -s /bin/bash makepkg-user
echo -e "makepkg-password\nmakepkg-password" | passwd makepkg-user
echo "makepkg-user ALL=(ALL) NOPASSWD: ALL" | (EDITOR="tee -a" visudo)

# download packer
# curl -o /home/makepkg-user/packer.tar.gz https://aur.archlinux.org/cgit/aur.git/snapshot/packer.tar.gz
curl -L -o /home/makepkg-user/packer-20160301-1-any.pkg.tar.xz https://github.com/binhex/arch-packages/raw/master/compiled/packer-20160301-1-any.pkg.tar.xz
# cd /home/makepkg-user
# su -c "tar -xvf packer.tar.gz" - makepkg-user

# install packer
# su -c "cd /home/makepkg-user/packer && makepkg -s --noconfirm --needed" - makepkg-user
pacman -U /home/makepkg-user/packer*.tar.xz --noconfirm

# install app using packer
su -c "packer -S $packer_packages --noconfirm" - makepkg-user

# remove base devel tools and packer
pacman -Ru base-devel git systemd --noconfirm

# delete makepkg-user account
userdel -r makepkg-user
