#!/bin/bash
sed -e s/'{$MOVIM_DOMAIN}'/$MOVIM_DOMAIN/ /etc/nginx/sites-available/default
exec "$@"
