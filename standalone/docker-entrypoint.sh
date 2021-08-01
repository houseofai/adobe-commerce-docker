#!/bin/bash

service php7.4-fpm start
service mysql start
service elasticsearch start
service nginx start
#/usr/sbin/nginx -g 'daemon off;'
tail -f /var/log/nginx/error.log /var/log/nginx/access.log
