#!/bin/bash
sed -i s/'{$NGINX_VHOST}'/$NGINX_VHOST/ /etc/nginx/sites-available/default
exec "$@"
