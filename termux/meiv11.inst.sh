#!/bin/sh
# Copyright (c) 2024 hidao80
# Released under the MIT license
# https://opensource.org/licenses/mit-license.php

# Update & Upgrade packages
pkg update
yes | pkg upgrade -y

# Install required packages
yes | pkg i -y nodejs redis postgresql git ffmpeg build-essential python libvips binutils vim xorgproto
npm i pnpm

# Keep communication active even during sleep mode
termux-wake-lock

# Setup environment variables
export GYP_DEFINES="android_ndk_path=''"
export PATH=$PATH:$HOME/node_modules/.bin
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export MISSKEY_DIR=$HOME/misskey
export NEW_CONF_FILE=$MISSKEY_DIR/.config/default.yml
export LAN_IP=$(ifconfig | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1| sort -hr | head -n 1)
export PORT=":3000"
echo "
export GYP_DEFINES=\"android_ndk_path=''\"
export PATH=\$PATH:\$HOME/node_modules/.bin
export CFLAGS=-I\$PREFIX/include
export LDFLAGS=-L\$PREFIX/lib
" >> $HOME/.bashrc

# Setup and Start Databases
initdb -D $PREFIX/var/lib/postgresql
pg_ctl -D $PREFIX/var/lib/postgresql start
createuser -s misskey
createdb -O misskey misskey
redis-server $PREFIX/etc/redis.conf --daemonize yes

# Get Mei-v11 repository
git clone --depth 1 https://github.com/mei23/misskey-v11.git $MISSKEY_DIR

# Build Mei-v11
cp $MISSKEY_DIR/.config/example.yml $NEW_CONF_FILE
sed -i "s/url: http.*/url: http:\/\/$LAN_IP$PORT\//" $NEW_CONF_FILE
sed -i "s/example-misskey-user/misskey/" $NEW_CONF_FILE
sed -i "s/example-misskey-pass/misskey/" $NEW_CONF_FILE
sed -i "s/fsStats\[0\]\./fsStats[0]?./" $MISSKEY_DIR/src/daemons/server-stats.ts
#sed -i "s/_os.cpus\(\).length/1/" $MISSKEY_DIR/built/boot/master.js

# Install a node that matches the environment
#npm i pnpm node-gyp core-js sharp msgpackr-extract utf-8-validate bufferutil --build-from-source
#pnpm rebuild

cd $MISSKEY_DIR
NODE_ENV=production npm_config_build_from_source=true pnpm i
NODE_ENV=production pnpm build
pnpm migrate

# Termux cannot read OS information.
sed -i "s/_os.cpus\(\).length/1/" $MISSKEY_DIR/built/boot/master.js

# Start Misskey-v11
pnpm start &
