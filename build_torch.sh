#!/usr/bin/env bash

set -e

git clone https://github.com/torch/distro.git /app/torch --recursive
cd /app/torch
echo yes | ./install.sh