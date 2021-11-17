#!/bin/sh
echo "cleaining up all exited docker images"
docker rm $(docker ps -a -q -f status=exited)
