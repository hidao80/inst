#!/bin/sh
# Copyright (c) 2024 hidao80
# Released under the MIT license
# https://opensource.org/licenses/mit-license.php

# Update & Upgrade packages
pkg update
pkg -y upgrade

# Install required packages
pkg i -y nodejs redis postgresql git ffmpeg build-essential python libvips binutils vim

# Setup environment variables
#export npm_config_build_from_source=true
export GYP_DEFINES="android_ndk_path=''"
#export LDFLAGS="-L/system/lib/"
#export CPPFLAGS="-I/data/data/com.termux/files/usr/include"
export PATH=$HOME/node_modules/.bin:$PATH
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

# Install a node that matches the environment
npm i pnpm
npm i node-gyp
npm i -D bufferutil
npm i -D utf-8-validate
npm i -D msgpackr-extract
#pnpm config set android_ndk_path $PREFIX
#pnpm rebuild

# Setup Postgresql
initdb -D $PREFIX/var/lib/postgresql

# Get Mei-v11 repository
git clone --depth 1 https://github.com/mei23/misskey-v11.git
cd misskey-v11

# Build Mei-v11
NODE_ENV=production pnpm i
