#! /bin/bash

set -e

log() {
    (echo -e "\e[91m\e[1m$*\e[0m")
}

cleanup() {
    if [ "$1" == "error" ]; then
        log "error occurred, cleaning up..."
    elif [ "$1" != "" ]; then
        log "$1 received, please wait a few seconds for cleaning up..."
    else
        log "cleaning up..."
    fi

    docker ps -a | grep -q $containerid && docker rm -f $containerid
}

trap "cleanup SIGINT" SIGINT
trap "cleanup SIGTERM" SIGTERM
trap "cleanup error" 0
trap "cleanup" EXIT

if [ "$1" == "" ]; then
    log "Fatal error: no recipe name given!"
    exit 1
fi

recipe="$1"

if [ $(basename $recipe .yml) == "$1" ]; then
    recipe="$recipe.yml"
fi

log  "Building $recipe in a container..."

randstr=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 8 | head -n 1)
containerid=appimage-build-$randstr
imageid=appimage-build

log "Building Docker container"
(set -x; docker build -t $imageid .)

log "Running container"
set -x
docker run -it \
    --name $containerid \
    --cap-add SYS_ADMIN \
    --device /dev/fuse \
    --security-opt apparmor:unconfined \
    -v $(readlink -f out)":/workspace/out" \
    $imageid \
    ./Recipe $recipe
