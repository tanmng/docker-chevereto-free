#!/bin/bash

# builder.sh
#
# A simple script to help build Docker images from corresponding directory

# Script settings
IMAGE_NAME="nmtan/chevereto"
BUILD_TAGS=( 1.0.7 latest installer )

for tag in "${BUILD_TAGS[@]}"
do
    pushd .
    echo "Building ${tag} from directory ${tag}/"
    cd ${tag}
    # pwd
    echo "docker build -t ${IMAGE_NAME}:${tag} ."
    docker build -t ${IMAGE_NAME}:${tag} .
    popd
done

