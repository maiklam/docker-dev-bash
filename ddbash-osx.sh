#!/usr/local/bin/bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

DEV_DOCKERFILE_TEMPLATE=$DIR/docker/Dockerfile.dev.template
DEV_DOCKERFILE=$DIR/docker/Dockerfile.dev

### check for which base image to use ###
declare -A imagemap
imagemap[node5]="node:5"
imagemap[ruby230]="ruby:2.3.0"

### create dockerfile with selected base image ###
function createDockerfile() {
  BASE_IMAGE=${imagemap[$1]}
  sed "s/%%BASE:TAG%%/${BASE_IMAGE}/g" ${DEV_DOCKERFILE_TEMPLATE} > ${DEV_DOCKERFILE}
}

### check if dev docker image exist ###
function doesDevImageExist() {
  docker images | grep "$1" | wc -l
}

### build dev docker image ###
function buildDevDockerImage() {
  IMAGE=$1
  echo -e "\n******* BUILD DEV IMAGE: ${IMAGE} *******\n"
	docker build --no-cache=true -t ${IMAGE} -f ${DEV_DOCKERFILE} $DIR
}

function printInvalidImageError() {
  echo ""
  if [ $# -eq 0 ]; then
    echo "#?!> ERR: Which dev image to use?"
  else
    echo "#?!> Base image for $1 not defined"
  fi
  echo "#?!> Available images: [${!imagemap[@]}]"
  echo ""
}

if [ $# -eq 0 ]; then
  printInvalidImageError
else
  if test "${imagemap[$1]+isset}"; then
    DEV_IMAGE=$1_dev

    imageExist=`doesDevImageExist ${DEV_IMAGE}`
    if [ $imageExist -eq 0 ]; then
      echo "Image ${DEV_IMAGE} does not exist. Creating..."
      createDockerfile $1
      buildDevDockerImage $DEV_IMAGE
    fi

    echo -e "\n******* START DEV CONTAINER: *******\n"
    $DIR/run-dev-docker-osx.sh ${DEV_IMAGE}
  else
    printInvalidImageError $1
  fi
fi
