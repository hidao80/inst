#!/bin/sh
# Copyright (c) 2024 hidao80
# Released under the MIT license
# https://opensource.org/licenses/mit-license.php

# Update & Upgrade packages
pkg update
yes | pkg upgrade

# Install required packages
yes | pkg i nodejs redis postgresql git ffmpeg build-essential python libvips binutils vim xorgproto

# Keep communication active even during sleep mode
termux-wake-lock

# Setup environment variables
export GYP_DEFINES="android_ndk_path=''"
export PATH=$HOME/node_modules/.bin:$PATH
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export NEW_CONF_FILE=.config/default.yml
export LAN_IP=$(ifconfig | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1| sort -hr | head -n 1)

echo "
export GYP_DEFINES=\"android_ndk_path=''\"
export PATH=\$HOME/node_modules/.bin:\$PATH
export CFLAGS=-I\$PREFIX/include
export LDFLAGS=-L\$PREFIX/lib
" >> $HOME/.bashrc

# Setup and Start Databases
initdb -D $PREFIX/var/lib/postgresql
pg_ctl -D $PREFIX/var/lib/postgresql start
redis-server &

# Get Mei-v11 repository
git clone --depth 1 https://github.com/mei23/misskey-v11.git

# Install a node that matches the environment
# The following packages cannot be built in Termux because they require glibc.
npm i pnpm node-gyp core-js sharp msgpackr-extract utf-8-validate bufferutil
pnpm rebuild

yes | pkg upgrade

# Build Mei-v11
cd misskey-v11
cp .config/example.yml $NEW_CONF_FILE
export FIX=src/daemons/server-stats.ts
sed -i "9s/^/#/" $NEW_CONF_FILE
sed -i "10s/^/url: http:\/\/$LAN_IP:3000/" $NEW_CONF_FILE
sed -i "s/available: fsStats\[0\]\.available,/available: fsStats[0]?.available,/" $FIX
sed -i "s/free: fsStats\[0\]\.available,/free: fsStats[0]?.available,/" $FIX
sed -i "s/total: fsStats\[0\]\.size,//" $FIX
NODE_ENV=production pnpm i
NODE_ENV=production pnpm build

# Initialize Database
export PG_USERNAME=example-misskey-user
export PG_USERPASS=example-misskey-pass
export PG_DB_NAME=misskey
createdb $PG_DB_NAME
createuser -s $PG_USERNAME
psql -c "ALTER USER \"$PG_USERNAME\" WITH PASSWORD '$PG_USERPASS';" $PG_DB_NAME
pnpm migrate

# Start Misskey-v11
NODE_ENV=production pnpm start
