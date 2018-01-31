#!/bin/bash
set -eo pipefail

function login () {
    echo "Logging to Docker hub"
    docker login -u ${DOCKER_USER_NAME} -p ${DOCKER_PWD}
}

function build () {
    echo "Building the Docker image"
    cd weave-cloud/apps/frontend
    if ! docker build -t chaosiq/demos-frontend-app .; then
        cd -
        echo "failed building frontend docker image"
        return 1
    fi
    cd -
}

function publish () {
    docker tag chaosiq/demos-frontend-app chaosiq/demos-frontend-app:$TRAVIS_TAG
    
    echo "Publishing to the Docker repository"
    docker push chaosiq/demos-frontend-app:$TRAVIS_TAG
    docker push chaosiq/demos-frontend-app:latest
}

function main () {
    login || return 1
    build || return 1

    if [[ $TRAVIS_TAG =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        publish || return 1
    fi
}

main "$@" || exit 1
exit 0
