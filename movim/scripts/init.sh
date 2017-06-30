#!/bin/bash

cp /opt/config/db.inc.php /var/www/movim/config/db.inc.php

service php7.0-fpm start

chown -R www-data: /var/www/
chmod -R u+rwx /var/www/

su - www-data php /var/www/daemon.php start --url=http://{$MOVIM_DOMAIN}/ --port={$MOVIM_PORT} --interface={$MOVIM_INTERFACE} --verbose --debug "$@"
