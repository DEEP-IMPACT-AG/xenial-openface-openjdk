#!/usr/bin/env bash

set -e

git clone https://github.com/cmusatyalab/openface.git /app/openface
cd /app/openface 
git submodule init 
git submodule update
./models/get-models.sh
pip install -r requirements.txt
python setup.py install
./data/download-lfw-subset.sh