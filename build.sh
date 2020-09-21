#!/bin/bash
docker network create --driver=bridge hadoop

docker build -t kshitij/hadoop .
