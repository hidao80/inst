#!/bin/sh
# Copyright (c) 2024 hidao80
# Released under the MIT license
# https://opensource.org/licenses/mit-license.php

# Update & Upgrade packages
pkg update
pkg -y upgrade

# Install required packages
pkg i -y nodejs redis postgresql git ffmpeg build-essential python libvips

# Install a node that matches the environment
npm i pnpm
nop i node-gyp

export CXXFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

# Setup Postgresql
initdb -D $PREFIX/var/lib/postgresql

# Get Mei-v11 repository
git clone https://github.com/mei23/misskey-v11.git
cd misskey-v11

# Build Mei-v11
NODE_ENV=production ~/node_modules/.bin/pnpm i
