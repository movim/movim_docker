#!/bin/bash
sed -i s/'{$NGINX_VHOST}'/$NGINX_VHOST/ /etc/nginx/sites-available/default
sed -i s/'{$MOVIM_PORT}'/$MOVIM_PORT/ /etc/nginx/sites-available/default
exec "$@"
