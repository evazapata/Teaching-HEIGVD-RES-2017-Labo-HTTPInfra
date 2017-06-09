#!/usr/bin/env bash
######################################################
# Name:             demo.sh
# Author:           Denise Gemesio & Ludovic Delafontaine
# Date:             June 2017
# Description:      Automates the demonstration for the RES lab for step 1
# Documentation:    https://github.com/evazapata/Teaching-HEIGVD-RES-2017-Labo-HTTPInfra
######################################################

######################################################
# In case of problems, stops the script
set -e
set -u

######################################################
# Constants
IMAGE_NAME=res/apache-php
IMAGE_SOURCE=docker-images/apache-php-image/

SOURCE_PORT=80
DEST_PORT=80

######################################################
# Script
echo "This is the demo script for Step 1: Static HTTP server with apache httpd."
read -p "Press <Enter> to run the demo."

echo "Building docker image..."
docker build --tag "$IMAGE_NAME" "$IMAGE_SOURCE"

echo "Running docker image..."
containerId=$(docker run --detach --publish $SOURCE_PORT:$DEST_PORT "$IMAGE_NAME")

echo "You can now open a browser and access to: http://localhost:$SOURCE_PORT"
read -p "Press <Enter> to quit the demo."

echo "Killing container..."
docker kill "$containerId"

echo "Removing docker image..."
docker rmi --force res/apache-php

echo "Demo done !"
