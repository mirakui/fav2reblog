#!/bin/bash -e

NAME=fav2reblog
IMAGE_PREFIX=gcr.io/mirakui-1073
TAG_PREFIX=mirakui
DOCKER_MACHINE_NAME=default
NEW_VERSION=$1

function usage() {
  echo "Usage: $0 <NEW_VERSION>"
  exit 1
}

if [ $NEW_VERSION ]; then
  echo -n "Are you sure to deploy $NAME ($NEW_VERSION)? (y/n): "
  read yn
  if [ $yn != "y" ]; then
    echo "aborted"
    exit 1
  fi
else
  usage
fi


NEW_TAG=$TAG_PREFIX/$NAME:$NEW_VERSION
NEW_IMAGE_URI=$IMAGE_PREFIX/$NAME:$NEW_VERSION

if [ `docker-machine status $DOCKER_MACHINE_NAME` = "Stopped" ]; then
  echo "Starting docker-machine $DOCKER_MACHINE_NAME"
  docker-machine start $DOCKER_MACHINE_NAME
fi

if [ -n $DOCKER_HOST ]; then
  echo "Exporting docker-machine env"
  eval $(docker-machine env $DOCKER_MACHINE_NAME)
  export DOCKER_TLS_VERIFY
  export DOCKER_HOST
  export DOCKER_CERT_PATH
  export DOCKER_MACHINE_NAME
fi

set -x
cd docker
docker build -t $NEW_TAG .
docker tag $NEW_TAG $NEW_IMAGE_URI
gcloud docker push $NEW_IMAGE_URI
if kubectl get rc $NAME; then
  kubectl rolling-update $NAME --image=$NEW_IMAGE_URI
else
  kubectl run $NAME --image=$NEW_IMAGE_URI
fi
kubectl describe pods $NAME
