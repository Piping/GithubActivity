#!/usr/bin/env bash

cd /etc/nginx

if [ -f ./nginx.conf.bak && -z $1 ]; then
    mv nginx.conf.bak nginx.conf
elif [ -z $1 ]; then
    sed -i.bak "s|proxy_pass.*|proxy_pass http://${1}:8080/activity/|" nginx.conf
fi

#TODO: check if the service faile to run after hot swap
service nginx reload