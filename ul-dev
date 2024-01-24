#!/bin/sh
# Set up UserLAnd as a basic development environment.
# 
# Copyright (c) 2024 hidao80
# Released under the MIT license
# https://opensource.org/licenses/mit-license.php

apt update
apt upgrade -y

# for Japanese
apt -y install language-pack-ja language-selector-common
apt -y install $(check-language-support)
update-locale LANG=ja_JP.UTF-8
apt -y install fcitx-mozc
im-config -n fcitx
ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

if [ "$GTK_IM_MODULE" = "" ]; then
echo "
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export DefaultIMModule=fcitx" >> $HOME/.profile
fi

apt install -y \
    software-properties-common \
    iputils-ping net-tools build-essential \
    docker docker-compose \
    apache2 nginx \
    vim nodejs npm yarn vite python3 pip ruby php-fpm \
    mariadb-server postgresql postgresql-contrib sqlite3 \
    php-mysql php-pgsql php-sqlite3 php-curl

sed -i 's/Listen\ 80/Listen\ 8080/g' /etc/apache2/ports.conf

service apache2 start
