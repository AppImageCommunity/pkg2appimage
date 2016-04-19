#!/bin/bash

# Build on Travis CI with or without Docker

set -e

if [ ! $(env | grep TRAVIS_JOB_ID ) ] ; then
  echo "This script is supposed to run on Travis CI"
  exit 1
fi

RECIPE="${1}"
DOCKER=$(echo "${RECIPE}" | cut -d "-" -f 1) # Allow e.g., a recipe called "inkscape-standalone" to use the "inkscape" Docker image

mkdir -p ./out/

if [ -f recipes/$RECIPE/Dockerfile ] && [ -f recipes/$RECIPE/Recipe ] ; then
  # There is a Dockerfile, hence build using Docker
  mv recipes/$RECIPE/Recipe ./out/Recipe
  sed -i -e 's|sudo ||g' ./out/Recipe # For subsurface recipe
  docker run -i -v ${PWD}/out:/out probonopd/appimages:$DOCKER /bin/bash -ex /out/Recipe
elif [ -f recipes/$RECIPE/Recipe ] ; then
  # There is no Dockerfile but a Recipe, hence build without Docker
  bash -ex recipes/$RECIPE/Recipe
else
  # There is no Recipe
  echo "Recipe not found, is RECIPE missing?"
  exit 1
fi

ls -lh out/*.AppImage
