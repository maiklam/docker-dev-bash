#!/usr/local/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "#> Bash version: ${BASH_VERSION}"

### The docker machine magic numbers for alligning uid's and guid's
DOCKER_UID=1000
DOCKER_GID=100
DOCKER_GROUP_ID=100

USER_GUFF="-e USERNAME=$(whoami) -e UID=${DOCKER_UID} -e GID=${DOCKER_GID} -e DOCKER_GROUP_ID=${DOCKER_GROUP_ID}"

TMPDIR="/home/$(whoami)/.tmp"
BUILD_VOLUMES="-v ${HOME}/.npm:/home/$(whoami)/.npm
               -v ${HOME}/npm/:/home/$(whoami)/npm
               -v ${HOME}/.npmrc:/home/$(whoami)/.npmrc
               -v ${HOME}/.cache/bower/:/home/$(whoami)/.cache/bower
               -v ${PWD}:/data
               -v ${TMPDIR}
               -v /var/run:/run"

IMAGE=$1
echo "#> Using image [$IMAGE]"

function isContainerRunning() {
  docker ps | grep "$1" | wc -l
}

CONTAINER_NAME="${PWD##*/}.${IMAGE}"
BUILD_VARS="-e TMPDIR=${TMPDIR}"

BASH_WITH_PROMPT="bash --rcfile <(
  echo 'alias ll=\"ls -l --color=auto\"';
  echo 'PS1=\"\n${CONTAINER_NAME} \[\033[0;33m\]\w\[\033[0m\] > \"'
)"

hasExit=`docker ps -f status=exited | grep ${CONTAINER_NAME}`
if [ "x$hasExit" != "x" ]; then
    echo "Has exited Container, cleaning up"
    docker rm ${CONTAINER_NAME}
fi

isRunning=`isContainerRunning ${CONTAINER_NAME}`
if [ $isRunning -eq 0 ]; then
  echo "Container [$CONTAINER_NAME] is not running. Starting..."
  docker run -dt \
    ${USER_GUFF} \
    --net=host \
    ${VOLUMES_FROM} \
    ${BUILD_VOLUMES} \
    ${BUILD_VARS} \
    --name ${CONTAINER_NAME} \
    ${IMAGE} bash
  sleep 1 # to create user
fi;

isRunning=`isContainerRunning ${CONTAINER_NAME}`
if [ $isRunning -eq 0 ]; then
  echo "ERROR> Container with name [$CONTAINER_NAME] not found. This is bad :("
fi

docker exec -u $(whoami) -it ${CONTAINER_NAME} bash -c "${BASH_WITH_PROMPT}"
