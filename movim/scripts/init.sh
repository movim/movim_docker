#!/bin/bash

cp /opt/config/db.inc.php /var/www/movim/config/db.inc.php

service php7.0-fpm start

git pull # To update the Movim source-code
php composer.phar install # To update the libraries
php mud.php db --set # Adapt Movim schema if required

chown -R www-data:www-data /var/www/ \
&& chmod -R u+rwx /var/www/

su - www-data php /var/www/daemon.php start --url=$MOVIM_DOMAIN --port=$MOVIM_PORT --interface=$MOVIM_INTERFACE --verbose --debug "$@"
