#!/usr/bin/env bash
######################################################
# Name:             demo.sh
# Author:           Denise Gemesio & Ludovic Delafontaine
# Date:             June 2017
# Description:      Automates the demonstration for the RES lab for step 3
# Documentation:    https://github.com/evazapata/Teaching-HEIGVD-RES-2017-Labo-HTTPInfra
######################################################

######################################################
# In case of problems, stops the script
set -e
set -u

######################################################
# Constants
ROOT=$(pwd)

STATIC_IMAGE_NAME=res/apache-php
STATIC_IMAGE_SOURCE=docker-images/apache-php-image/
STATIC_IP_ADDRESS="172.17.0.2:80"
STATIC_SOURCE_PORT=1234
STATIC_DEST_PORT=80

DYNAMIC_IMAGE_NAME=res/express-image
DYNAMIC_IP_ADDRESS="172.17.0.3:3000"
DYNAMIC_IMAGE_SOURCE=docker-images/express-image/
DYNAMIC_SOURCE_PORT=4321
DYNAMIC_DEST_PORT=3000

REVERSE_IMAGE_NAME=res/apache-reverse-proxy
REVERSE_IMAGE_SOURCE=docker-images/apache-reverse-proxy/
REVERSE_SOURCE_PORT=8080
REVERSE_DEST_PORT=80

######################################################
# Script

echo "This is the demo script for Step 5: Dynamic reverse proxy configuration."
read -p "Press <Enter> to run the demo."

echo "Setting permissions..."
chmod -R +x ./*

echo "Installing npm modules..."
cd "$DYNAMIC_IMAGE_SOURCE/src"
npm install --save chance
npm install --save express
cd "$ROOT"

echo "Building docker images..."
docker build --tag "$STATIC_IMAGE_NAME" "$STATIC_IMAGE_SOURCE"
docker build --tag "$DYNAMIC_IMAGE_NAME" "$DYNAMIC_IMAGE_SOURCE"
docker build --tag "$REVERSE_IMAGE_NAME" "$REVERSE_IMAGE_SOURCE"

echo "Starting $STATIC_IMAGE_NAME image..."
docker run --detach --publish $STATIC_SOURCE_PORT:$STATIC_DEST_PORT $STATIC_IMAGE_NAME

echo "Starting $DYNAMIC_IMAGE_NAME image..."
docker run --detach --publish $DYNAMIC_SOURCE_PORT:$DYNAMIC_DEST_PORT $DYNAMIC_IMAGE_NAME

echo "Starting $REVERSE_IMAGE_NAME image..."
docker run --env STATIC_APP="$STATIC_IP_ADDRESS" --env DYNAMIC_APP="$DYNAMIC_IP_ADDRESS" --detach --publish $REVERSE_SOURCE_PORT:$REVERSE_DEST_PORT $REVERSE_IMAGE_NAME

echo "You can now try to access to demo.res.ch:$STATIC_DEST_PORT, it's the $STATIC_IMAGE_NAME image, shouldn't be accessible."
echo "You can now try to access to demo.res.ch:$DYNAMIC_DEST_PORT, it's the $DYNAMIC_IMAGE_NAME image, shouldn't be accessible."
echo "You can now try to access to demo.res.ch:$REVERSE_SOURCE_PORT, it's the $REVERSE_IMAGE_NAME image, should be accessible !"
read -p "Press <Enter> to quit the demo."

echo "Killing containers..."
docker kill $(docker ps -a -q)

echo "Removing docker images..."
docker rm $(docker ps -a -q)

echo "Demo done !"
