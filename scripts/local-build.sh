#!/bin/bash
# local-build.sh
#
# A script to help build the Docker image locally
# Unforunately Docker now do not allow free tier account to build image using
# their hooks any more, so this script is intended to be used on my local build server.
# Virtually this only needs docker installed

echo "------ LOCAL BUILD: STARTED -------"

DOCKER_HUB_NAME=nmtan/chevereto
VERSION_LIST_FILE=`dirname $0`/../versions
BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`

APP_FILE_DIR=app/

# Confirm that the machine has all the utilities needed
# TODO

# Mark that the version we just downloaded is also the latest one
latest_version=true


function download_version() {
  version=$1
  if [ ! -d $APP_FILE_DIR ]; then
    # Make sure to create the dir
    mkdir -p $APP_FILE_DIR
  fi
  pushd .
  cd $APP_FILE_DIR
  wget -O chevereto.zip -L "https://github.com/rodber/chevereto-free/archive/refs/tags/${version}.zip"
  unzip -o chevereto.zip
  unzip_dir="chevereto-free-${version}"
  if $latest_version; then
    # This is actually not needed, after we create the sym-link latest, subsequent creation will simply fail
    ln -s ${unzip_dir} latest
    latest_version=false
  fi
  rm chevereto.zip
  
  # Copy in the config file
  case "$version" in
    latest)
    1.6.*)
      # Version 1.6 up, developer already included the settings-env file
      # Nothing to do
      ;;
    *)
      # Older version, we need the settings file
      rsync -avip ../settings.php ${unzip_dir}/app/
      ;;
  esac
  popd
}

function build_image(){
    if [ $#  -lt 1 ]; then
        # missing the damn tag
        return 0;
    fi

    tag_name="${1}"
    image_full_name="${DOCKER_HUB_NAME}:${tag_name}"
    case "${tag_name}" in
      1.[3-6].*)
        # These versions support php 7.4
        docker build --rm --build-arg BUILD_DATE="${BUILD_DATE}" \
            --build-arg CHEVERETO_VERSION="${1}" \
            --build-arg PHP_VERSION="7.4-apache" \
            --build-arg COMPOSER_VERSION="2" \
            -t "${image_full_name}" .
      ;;
      1.2.*)
        # These versions support php 7.3
        docker build --rm --build-arg BUILD_DATE="${BUILD_DATE}" \
            --build-arg CHEVERETO_VERSION="${1}" \
            --build-arg COMPOSER_VERSION="1" \
            --build-arg PHP_VERSION="7.3-apache" \
            -t "${image_full_name}" .
      ;;
    esac

    # docker push "${image_full_name}"
}

while read -r tag; do
    echo "Building the image ${DOCKER_HUB_NAME}:${tag}"
    download_version "${tag}"
    build_image "${tag}"
done < ${VERSION_LIST_FILE}

# Build the lates image
build_image "latest"

echo "------ LOCAL BUILD: ENDED -------"
