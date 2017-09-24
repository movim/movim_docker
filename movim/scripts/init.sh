#!/bin/bash

cp /opt/config/db.inc.php /var/www/movim/config/db.inc.php

sed -i s/'{$POSTGRES_USER}'/$POSTGRES_USER/ /var/www/movim/config/db.inc.php
sed -i s/'{$POSTGRES_PASSWORD}'/$POSTGRES_PASSWORD/ /var/www/movim/config/db.inc.php
sed -i s/'{$POSTGRES_DB}'/$POSTGRES_DB/ /var/www/movim/config/db.inc.php

service php7.0-fpm start

php mud.php db --set # Adapt Movim schema if required
php mud.php config --username=$MOVIM_ADMIN --password=$MOVIM_PASSWORD # Set credentials for the admin interface

chown -R www-data:www-data /var/www \
&& chmod -R u+rwx /var/www

exec su -s /bin/bash -c "php /var/www/movim/daemon.php start --url=$MOVIM_DOMAIN --port=$MOVIM_PORT --interface=$MOVIM_INTERFACE --verbose --debug" www-data
