#!/bin/bash

docker run --rm -it \
    --volume $PWD:/data \
    --user $(id -u):$(id -g) \
    --env JOURNAL=joss \
    openjournals/inara \
    -o pdf paper.md
