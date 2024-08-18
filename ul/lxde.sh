#!/bin/sh
# (c) 2024 hidao80. Licensed under the MIT License.

. /etc/os-release

if [ "$ID" = "ubuntu" ];then
apt update
apt -y upgrade
apt install -y locales-all
ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
DEBIAN_FRONTEND=noninteractive apt install -y task-lxde-desktop
apt install -y task-japanese-desktop ibus-mozc
fi

if [ "$ID" = "debian" ];then
apt update
apt -y upgrade
apt install -y locales-all
ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
DEBIAN_FRONTEND=noninteractive apt -y install lxde
#dpkg-reconfigure locales
#. /etc/default/locale
#dpkg-reconfigure tzdata
apt -y install task-japanese task-japanese-desktop fcitx-mozc dbus-x11
fi

curl -sLkO https://downloads.vivaldi.com/stable/vivaldi-stable_arm64.deb
curl -sLk https://code.visualstudio.com/sha/download?build=stable\&os=linux-deb-arm64 --output vscode_arm64_latest.deb

apt install -y \
    software-properties-common \
    iputils-ping net-tools build-essential \
    vim \
    ./vivaldi-stable_arm64.deb \
    ./vscode_arm64_latest.deb
