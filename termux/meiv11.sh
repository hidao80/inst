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

# Setup Postgresql
initdb -D $PREFIX/var/lib/postgresql

# Get Mei-v11 repository
git clone --depth 1 https://github.com/mei23/misskey-v11.git

# Install a node that matches the environment
npm i pnpm node-gyp core-js sharp msgpackr-extract utf-8-validate bufferutil
pnpm rebuild

yes | pkg upgrade

# Build Mei-v11
cd misskey-v11
cp .config/example.yml .config/default.yml 
sed -i "9s/^/#/" .config/default.yml
sed -i "10s/^/url: http:\/\/localhost" .config/default.yml
sed -i "19s/^/#/" .config/default.yml
sed -i "20s/^/port: 80" .config/default.yml
NODE_ENV=production pnpm i
NODE_ENV=production pnpm build

# Initialize Database
pnpm migrate
psql -c "ALTER USER example-misskey-user WITH PASSWORD 'example-misskey-pass';"

# Start Misskey-v11
NODE_ENV=production pnpm start
