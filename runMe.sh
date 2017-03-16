#!/bin/bash

function hwbuild(){
    docker build --tag=ng HW4/nginx/
    docker build --tag=activity2 HW4/activity/
    #docker cp  nginx/swap.sh  ecs189_proxy_1:swap.sh
}

function hwup() {
    docker-compose -f ./HW4/nginx/docker-compose.yml -p ecs189 up -d
}

function hwdown() {
    docker rm -f $(docker ps -f network=ecs189_default -q)
    docker-compose -f ./HW4/nginx/docker-compose.yml -p ecs189 down --rmi local
}

function swap() {
    # ${variable name} $1 - the first argument: image_name
    docker_image_name=$1

    if [ -z $(docker image ls --filter reference=$docker_image_name -q) ]; then
        echo "Image '$docker_image_name' is not found! Try other Image Name"
        return 1
    fi

    if [ $(docker ps -f name=ecs189_${docker_image_name}_1 -q) ]; then
        echo "Replace the CURRENT RUNNING container of image: $docker_image_name"
        docker rm -f $(docker ps -f name=ecs189_${docker_image_name}_1 -q)
    fi

    new_container=$(docker run --network=ecs189_default --name=ecs189_${docker_image_name}_1 -d $docker_image_name)

    docker exec -it ecs189_proxy_1 bash /swap.sh ecs189_${docker_image_name}_1

    proxy_id=$(docker ps -f network=ecs189_default -f name=ecs189_proxy_1 --no-trunc -q )

    for id in $(docker ps --filter network=ecs189_default --no-trunc -q)
    do
        if [ $id != $new_container ] && [ $id != $proxy_id ]; then
           docker rm -f $id
           break
        fi
    done

    #cat /proc/self/cgroup | grep "cpu:/" | sed 's/\([0-9]\):cpu:\/docker\///g'
    #old_container=$(docker exec -it ecs189_proxy_1 bash /swap.sh $1 | sed 's|proxy_pass http://\(.*\):.*|\1|' | sed '1q' | xargs)
    #rm -f ecs189_${old_container}_1 || docker rm -f ${old_container}
}