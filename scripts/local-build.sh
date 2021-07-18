#!/bin/bash
# local-build.sh
#
# A script to help build the Docker image locally
# Unforunately Docker now do not allow free tier account to build image using
# their hooks any more, so this script is intended to be used on my local build server.
# Virtually this only needs docker installed

echo "------ LOCAL BUILD: STARTED -------"

DOCKER_HUB_NAME=nmtan/chevereto
VERSION_LIST_FILE=`realpath $0`/../versions
BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`

function build_image(){
    if [ $#  -lt 1 ]; then
        # missing the damn tag
        return 0;
    fi

    tag_name="${1}"
    image_full_name="${DOCKER_HUB_NAME}:${tag_name}"
    case "${tag_name}" in
      latest)
        # Latest version - we do not need the version argument - latest version is defined in Dockerfile itself
        docker build --rm --build-arg BUILD_DATE="${BUILD_DATE}" \
            --build-arg CHEVERETO_VERSION="master" \
            -t "${image_full_name}" .
      ;;
      installer)
        # Latest version - we do not need the version argument - latest version is defined in Dockerfile itself
        docker build --rm --build-arg BUILD_DATE="${BUILD_DATE}" \
            -f Dockerfile-installer \
            -t "${image_full_name}" .
      ;;
      1.3.*)
        # These versions support php 7.3
        docker build --rm --build-arg BUILD_DATE="${BUILD_DATE}" \
            --build-arg CHEVERETO_VERSION="${1}" \
            -t "${image_full_name}" .
      ;;
      1.2.*)
        # These versions support php 7.3
        docker build --rm --build-arg BUILD_DATE="${BUILD_DATE}" \
            --build-arg PHP_VERSION="7.3-apache" \
            --build-arg CHEVERETO_VERSION="${1}" \
            -t "${image_full_name}" .
      ;;
      1.1.*)
        # These versions support php 7.2
        docker build --rm --build-arg BUILD_DATE="${BUILD_DATE}" \
            --build-arg CHEVERETO_VERSION="${1}" \
            --build-arg PHP_VERSION="7.2-apache" \
            -t "${image_full_name}" .
        ;;
      1.0.1[0-3]|1.0.[6-9])
        # These versions support PHP 7.1
        docker build --rm --build-arg BUILD_DATE="${BUILD_DATE}" \
            --build-arg CHEVERETO_VERSION="${1}" \
            --build-arg PHP_VERSION="7.1.23-apache" \
            -t "${image_full_name}" .
        ;;
      *)
        # These versions support PHP below 7.1
        docker build --rm --build-arg BUILD_DATE="${BUILD_DATE}" \
            --build-arg CHEVERETO_VERSION="${1}" \
            --build-arg PHP_VERSION="7.0.32-apache" \
            -t "${image_full_name}" .
        ;;
    esac

    docker push "${image_full_name}"
}

while read -r tag; do
    echo "Building the image ${DOCKER_HUB_NAME}:${tag}"
    build_image "${tag}"
done < ${VERSION_LIST_FILE}

echo "------ LOCAL BUILD: ENDED -------"
