#!/bin/sh

set -e

DESCRIBE=$(git describe --match release/*.* --abbrev=4 --dirty=--DIRTY--)
VERSION=$(echo $DESCRIBE | sed  's_release/\(.*\)_\1_')
TAG=deepimpact/xenial-openface-openjdk:${VERSION}

docker build --no-cache -t ${TAG} .
