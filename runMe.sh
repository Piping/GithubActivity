#!/bin/bash

function hwbuild(){
    docker build --tag=ng nginx/
    docker build --tag=activity2 activity/
    #docker cp  nginx/swap.sh  ecs189_proxy_1:swap.sh
}

function hwup() {
    docker-compose -f ./nginx/docker-compose.yml -p ecs189 up -d
}

function hwdown() {
    docker-compose -f ./nginx/docker-compose.yml -p ecs189 down --rmi local
}

function swap() {
    docker exec -it ecs189_proxy_1 bash /swap.sh
}