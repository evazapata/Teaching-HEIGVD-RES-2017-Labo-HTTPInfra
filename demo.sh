#!/usr/bin/env bash
######################################################
# Name:             demo.sh
# Author:           Denise Gemesio & Ludovic Delafontaine
# Date:             June 2017
# Description:      Automates the demonstration for the RES lab for step 2
# Documentation:    https://github.com/evazapata/Teaching-HEIGVD-RES-2017-Labo-HTTPInfra
######################################################

######################################################
# In case of problems, stops the script
set -e
set -u

######################################################
# Constants
ROOT=$(pwd)

IMAGE_NAME=res/express-image
IMAGE_SOURCE=docker-images/express-image/

SOURCE_PORT=80
DEST_PORT=3000

######################################################
# Script
echo "This is the demo script for Step 2: Dynamic HTTP server with express.js."
read -p "Press <Enter> to run the demo."

echo "Installing npm modules..."
cd "$IMAGE_SOURCE/src"
npm install --save chance
npm install --save express
cd "$ROOT"

echo "Building docker image..."
sudo docker build --tag "$IMAGE_NAME" "$IMAGE_SOURCE"

echo "Running docker image..."
containerId=$(sudo docker run --detach --publish $SOURCE_PORT:$DEST_PORT "$IMAGE_NAME")

echo "You can now open a browser and access to: http://localhost:$SOURCE_PORT"
read -p "Press <Enter> to quit the demo."

echo "Killing container..."
sudo docker kill "$containerId"

echo "Removing docker image..."
sudo docker rmi --force "$IMAGE_NAME"

echo "Demo done !"
