#!/usr/bin/bash
set -e

pacman -Syu base-devel git --noconfirm

# add user 'buildaur'
useradd buildaur -m
echo "buildaur ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers
chmod -R a+rw .

# build yay
sudo -H -u buildaur git clone https://aur.archlinux.org/yay.git
(
    cd yay
    sudo -H -u buildaur makepkg --syncdeps --install --noconfirm
)

# add old repo
if [ -f ./repo.txt ]; then
    repocfg="\n[custom]\nSigLevel = Optional TrustAll\nServer"
    repourl=$(cat ./repo.txt)
    echo "${repocfg} = ${repourl}" >>/etc/pacman.conf
    pacman -Syu
fi

mkdir build
for pkgname in $(cat ./packages.txt); do
    sudo -H -u yay -S "${pkgname}" --noconfirm --builddir ./build
done

ls -lh .
