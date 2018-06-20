#!/usr/bin/env bash
set -euo pipefail

if ! [ -e index.php -a -e daemon.php ]; then
	echo >&2 "Movim not found in $PWD - copying now..."
	if [ "$(ls -A)" ]; then
		echo >&2 "WARNING: $PWD is not empty - press Ctrl+C now if this is an error!"
		( set -x; ls -A; sleep 10 )
	fi
	tar cf - --one-file-system -C /usr/src/movim-${MOVIM_VERSION} . | tar xf -
	echo >&2 "Complete! Movim ${MOVIM_VERSION} has been successfully copied to $PWD"
fi

cat <<EOT > config/db.inc.php
<?php
\$conf = [
    'type'        => '$MOVIM_DB_TYPE',
    'database'    => '$MOVIM_DB_DB',
    'host'        => '$MOVIM_DB_HOST',
    'port'        => '$MOVIM_DB_PORT',
    'username'    => '$MOVIM_DB_USER',
    'password'    => '$MOVIM_DB_PASSWORD',
];
EOT

chown -R www-data:www-data $PWD && chmod -R u+rwx $PWD

php mud.php db --set
php mud.php config --username=$MOVIM_ADMIN --password=$MOVIM_PASSWORD

exec "$@"
