#!/usr/bin/env bash

cd /etc/nginx

if [ -f ./nginx.conf.bak ]; then
    mv nginx.conf.bak nginx.conf
else
    sed -i.bak "s|proxy_pass http://activity:8080/activity/|proxy_pass http://activity2:8080/activity/|" nginx.conf
fi

service nginx reload