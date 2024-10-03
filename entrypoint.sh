#!/usr/bin/bash
set -e

REPO_NAME="xgugugu"
REPO_URL="https://github.com/xgugugu/aur/releases/download/aur/"

pacman -Syu base-devel git wget --noconfirm

# add user 'buildaur'
useradd buildaur -m
echo "buildaur ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers
chmod -R a+rw .

# add old repo
if [[ $REPO_URL ]]; then
    repocfg="\n[${REPO_NAME}]\nSigLevel = Optional TrustAll\nServer = ${REPO_URL}"
    echo -e "${repocfg}" >>/etc/pacman.conf
    pacman -Syu
fi

# install or build yay
sudo -H -u buildaur mkdir build
# if pacman -Sy yay --noconfirm; then
    # echo "install yay from pacman"
# else
    (
        cd build
        sudo -H -u buildaur git clone https://aur.archlinux.org/yay.git
        (
            cd yay
            sudo -H -u buildaur makepkg --syncdeps --install --noconfirm
        )
    )
# fi

# build packages by yay
for pkgname in $(cat ./packages.txt); do
    sudo -H -u buildaur yay -S "${pkgname}" --noconfirm --builddir ./build
done

# add repo pkgs
mkdir dist
cp ./build/*/*.pkg.tar.zst ./dist || true
(
    cd dist
    if [[ $REPO_URL ]]; then
        wget -O "./${REPO_NAME}.db.tar.gz" "${REPO_URL}/${REPO_NAME}.db.tar.gz"
    fi
    repo-add "./${REPO_NAME}.db.tar.gz" ./*.pkg.tar.zst || true
    ls .
)
