#!/bin/sh
# Copyright (c) 2024 hidao80
# Released under the MIT license
# https://opensource.org/licenses/mit-license.php

. /etc/os-release

if [ "$ID" = "ubuntu" ];then
apt update
apt -y upgrade
#DEBIAN_FRONTEND=noninteractive apt -y install lxde
DEBIAN_FRONTEND=noninteractive apt -y imstall xfce4
apt -y install language-pack-ja
apt -y install language-selector-common
apt -y install $(check-language-support)
update-locale LANG=ja_JP.UTF-8
apt -y install fcitx-mozc
im-config -n fcitx
#dpkg-reconfigure tzdata
#timedatectl set-timezone JST
ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
#sudo sed -i 's/^#.*WaylandEnable=.*/WaylandEnable=false/' /etc/gdm3/custom.conf
fi

if [ "$ID" = "debian" ];then
apt update
apt -y upgrade
apt -y install lxde task-japanese task-japanese-desktop
dpkg-reconfigure locales
. /etc/default/locale
apt -y install fcitx-mozc dbus-x11
dpkg-reconfigure tzdata
fi

if [ "$GTK_IM_MODULE" = "" ]; then
echo "
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export DefaultIMModule=fcitx" >> $HOME/.profile
fi

echo "source ~/.profile
lxsession &" > ~/.xsessionrc

apt install -y \
    software-properties-common \
    iputils-ping net-tools build-essential \
    vim \
    chromium-browser
