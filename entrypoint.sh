#!/usr/bin/bash
set -e

pacman -Syu base-devel git --noconfirm

# add user 'buildaur'
useradd buildaur -m
echo "buildaur ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers
chmod -R a+rw .

# add old repo
if [ -f ./repo.txt ]; then
    repocfg="\n[custom]\nSigLevel = Optional TrustAll\nServer"
    repourl=$(cat ./repo.txt)
    echo -e "${repocfg} = ${repourl}" >>/etc/pacman.conf
    pacman -Syu
fi

# install or build yay
if pacman -Sy yay --noconfirm; then
    echo "install yay from pacman"
else
    sudo -H -u buildaur mkdir build
    (
        cd build
        sudo -H -u buildaur git clone https://aur.archlinux.org/yay.git
        (
            cd yay
            sudo -H -u buildaur makepkg --syncdeps --install --noconfirm
        )
    )
fi

# build packages by yay
for pkgname in $(cat ./packages.txt); do
    sudo -H -u buildaur yay -S "${pkgname}" --noconfirm --builddir ./build
done

# add repo pkgs
mkdir dist
cp ./build/*/*.pkg.tar.zst ./dist || true
(
    cd dist
    if [ -f ./repo.txt ]; then
        wget -O ./xgugugu.db.tar.gz "$(cat ./repo.txt)/xgugugu.db.tar.gz"
    fi
    repo-add ./xgugugu.db.tar.gz ./*.pkg.tar.zst || true
    ls .
)
