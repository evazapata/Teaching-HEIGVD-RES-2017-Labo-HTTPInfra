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
STATIC_SOURCE_PORT=2999
STATIC_DEST_PORT=80

DYNAMIC_IMAGE_NAME=res/express-image
DYNAMIC_IMAGE_SOURCE=docker-images/express-image/
DYNAMIC_SOURCE_PORT=3000
DYNAMIC_DEST_PORT=3000

REVERSE_IMAGE_NAME=res/apache-reverse-proxy
REVERSE_IMAGE_SOURCE=docker-images/apache-reverse-proxy/
REVERSE_SOURCE_PORT=80
REVERSE_DEST_PORT=3001

######################################################
# Script
containers=()

echo "This is the demo script for Step 3: Reverse proxy with apache (static configuration)."
read -p "Press <Enter> to run the demo."

echo "Installing npm modules..."
cd "$DYNAMIC_IMAGE_SOURCE/src"
npm install --save chance
npm install --save express
cd "$ROOT"

echo "Building docker images..."
sudo docker build --tag "$STATIC_IMAGE_NAME" "$STATIC_IMAGE_SOURCE"
sudo docker build --tag "$DYNAMIC_IMAGE_NAME" "$DYNAMIC_IMAGE_SOURCE"
#sudo docker build --tag "$REVERSE_IMAGE_NAME" "$REVERSE_IMAGE_SOURCE"

echo "Starting $STATIC_IMAGE_NAME image..."
containers+=$(sudo docker run --detach --publish $STATIC_SOURCE_PORT:$STATIC_DEST_PORT "$STATIC_IMAGE_NAME")

echo "Starting $DYNAMIC_IMAGE_NAME image..."
containers+=$(sudo docker run --detach --publish $DYNAMIC_SOURCE_PORT:$DYNAMIC_DEST_PORT "$DYNAMIC_IMAGE_NAME")

echo "Starting $REVERSE_IMAGE_NAME image..."
#containers+=$(sudo docker run --detach --publish $REVERSE_SOURCE_PORT:$REVERSE_DEST_PORT "$REVERSE_IMAGE_NAME")

echo "You can now try to access to localhost:$STATIC_SOURCE_PORT, it's the $STATIC_IMAGE_NAME image, shouldn't be accessible."
echo "You can now try to access to localhost:$DYNAMIC_SOURCE_PORT, it's the $DYNAMIC_IMAGE_NAME image, shouldn't be accessible."
echo "You can now try to access to localhost:$REVERSE_SOURCE_PORT, it's the $REVERSE_IMAGE_NAME image, should be accessible !"
read -p "Press <Enter> to quit the demo."

echo "Killing containers..."
for container in "${containers[@]}"; do
    sudo docker kill "${container}"
done


echo "Removing docker image..."
sudo docker rmi --force "$STATIC_IMAGE_NAME"
sudo docker rmi --force "$DYNAMIC_IMAGE_NAME"
sudo docker rmi --force "$REVERSE_IMAGE_NAME"

echo "Demo done !"
