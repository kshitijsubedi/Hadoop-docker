#!/bin/bash
docker run -itd --net=hadoop -p 50070:50070 -p 8088:8088 --name hadoop-master --hostname hadoop-master kshitij/hadoop

docker exec -it hadoop-master bash
