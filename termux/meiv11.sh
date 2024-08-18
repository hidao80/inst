#!/bin/sh
# (c) 2024 hidao80. Licensed under the MIT License.

# Install required packages
pkg i -y nodejs redis postgresql git ffmpeg build-essential

# Setting environment variables
export N_PREFIX=$PREFIX
export PATH=$N_PREFIX:$PATH
echo "
export N_PREFIX=$PREFIX
export PATH=$N_PREFIX/bin:$PATH
" > ~/.bashrc

# Install a node that matches the environment
npm i -g n
#n 18
pnpm i -g pnpm

# Setup Postgresql
initdb -D $PREFIX/var/lib/postgresql

# Get Mei-v11 repository
git clone https://github.com/meiv11/misskey-v11.git
cd misskey-v11

# Build Mei-v11
NODE_ENV=production pnpm i
