#!/bin/sh
# Copyright (c) 2024 hidao80
# Released under the MIT license
# https://opensource.org/licenses/mit-license.php

# Update & Upgrade packages
pkg update
yes | pkg upgrade

# Install required packages
yes | pkg i nodejs redis postgresql git ffmpeg build-essential python libvips binutils vim xorgproto

# Setup environment variables
export GYP_DEFINES="android_ndk_path=''"
export PATH=$HOME/node_modules/.bin:$PATH
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export NEW_CONF_FILE=.config/default.yml
export PGDATA=$PREFIX/var/lib/postgresql

echo "
export GYP_DEFINES=\"android_ndk_path=''\"
export PATH=\$HOME/node_modules/.bin:\$PATH
export CFLAGS=-I\$PREFIX/include
export LDFLAGS=-L\$PREFIX/lib
export PGDATA=\$PREFIX/var/lib/postgresql
" >> $HOME/.bashrc

# Setup and Start Databases
initdb
pg_ctl start
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
sed -i "9s/^/#/" $NEW_CONF_FILE
sed -i "10s/^/url: http:\/\/localhost/" $NEW_CONF_FILE
sed -i "18s/^/#/" $NEW_CONF_FILE
sed -i "19s/^/port: 80/" $NEW_CONF_FILE
NODE_ENV=production pnpm i
NODE_ENV=production pnpm build

# Initialize Database
export PG_USERNAME=example-misskey-user
export PG_USERPASS=example-misskey-pass
createdb misskey
createuser $PG_USERNAME
psql -c "ALTER USER \"$PG_USERNAME\" WITH PASSWORD '$PG_USERPASS';" misskey
pnpm migrate

# Start Misskey-v11
NODE_ENV=production pnpm start 2&> /dev/null
