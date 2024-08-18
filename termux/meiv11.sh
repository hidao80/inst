#!/bin/sh
# Copyright (c) 2024 hidao80
# Released under the MIT license
# https://opensource.org/licenses/mit-license.php

# Install required packages
pkg i -y nodejs redis postgresql git ffmpeg build-essential

# Setting environment variables
echo "
export N_PREFIX=~/.n
" > ~/.bashrc
source ~/.bashrc

# Install a node that matches the environment
npm i n
n 18
pnpm i pnpm

# Setup Postgresql
initdb -D $PREFIX/var/lib/postgresql

# Get Mei-v11 repository
git clone https://github.com/mei23/misskey-v11.git
cd misskey-v11

# Build Mei-v11
NODE_ENV=production pnpm i
