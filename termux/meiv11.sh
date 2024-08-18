#!/bin/sh
# Copyright (c) 2024 hidao80
# Released under the MIT license
# https://opensource.org/licenses/mit-license.php

# Update & Upgrade packages
pkg update
pkg -y upgrade

# Install required packages
pkg i -y nodejs redis postgresql git ffmpeg build-essential python libvips binutils

# Install a node that matches the environment
npm i pnpm
npm i node-gyp

export PATH=~/node_modules/.bin/:$PATH
export CXXFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

pnpm config set android_ndk_path $PREFIX

# Setup Postgresql
initdb -D $PREFIX/var/lib/postgresql

# Get Mei-v11 repository
git clone https://github.com/mei23/misskey-v11.git
cd misskey-v11

# Build Mei-v11
NODE_ENV=production pnpm i
