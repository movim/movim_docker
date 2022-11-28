#!/bin/sh

cd $MOVIM_HOME

copy_movim ()
{
	cd /tmp/movim
	tar cf - * | ( cd $MOVIM_HOME; tar xfp -)
	echo >&2 "Complete! Movim ${MOVIM_VERSION} has been successfully copied to $MOVIM_HOME"
	cd $MOVIM_HOME
	echo "$MOVIM_VERSION" > CTR_TAG
	# cleanup build files
	rm -rf /tmp/*
}

if [ ! -f CTR_TAG ] && [ -f VERSION ]; then
	echo "$(cat VERSION)" > CTR_TAG
fi

# copy image's movim version into workdir
if ! [ -e daemon.php -a -e public/index.php ]; then
	echo >&2 "Movim not found in $MOVIM_HOME - copying now..."
	if [ "$(ls -A)" ]; then
		echo >&2 "WARNING: $MOVIM_HOME is not empty - press Ctrl+C now if this is an error!"
		( set -x; ls -A; sleep 10 )
	fi
	copy_movim
elif ! [ "$MOVIM_VERSION" = $(cat CTR_TAG) ]; then
	echo >&2 "Image version $MOVIM_VERSION does not equal version $(cat CTR_TAG) found in $MOVIM_HOME"
	echo >&2 "- press Ctrl+C now to prevent overriding!"
	sleep 10
	echo >&2 "- overriding now..."
	copy_movim
fi

# check if password is a "file" or variable
if [ -n "${DB_PASSWORD_FILE:-}" ]; then
    # create secret from file
    export DB_PASSWORD=$(cat "$DB_PASSWORD_FILE")
elif [ -z "${DB_PASSWORD:-}" ]; then
    echo ">>> No DB_PASSWORD or DB_PASSWORD_FILE is set"
fi

### create movim .env configuration file
cat <<EOT > ${MOVIM_HOME}/.env
# Database configuration
DB_DRIVER=${DB_DRIVER:-pgsql}
DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-5432}
DB_DATABASE=${DB_DATABASE:-movim}
DB_USERNAME=${DB_USERNAME:-movim}
DB_PASSWORD=${DB_PASSWORD:-movim}

# Daemon configuration
DAEMON_URL=${DAEMON_URL:-https://public-movim.url/}
DAEMON_PORT=${DAEMON_PORT:-8080}
DAEMON_INTERFACE=${DAEMON_INTERFACE:-0.0.0.0}
DAEMON_DEBUG=${DAEMON_DEBUG:-false}
DAEMON_VERBOSE=${DAEMON_VERBOSE:-false}
EOT

### wait for database server to be available
#echo "Testing database server connection..."
#
#PING_CMD="ping -t 3 -c 1 $DB_HOST > /dev/null 2>&1"
#
#eval $PING_CMD
#
#if [[ $? -eq 0 ]]; then
#    echo "Connected!."
#else
#    echo -n "Waiting for connection..."
#
#    while true; do
#        eval $PING_CMD
#
#        if [[ $? -eq 0 ]]; then
#            echo
#            echo Connected.
#            break
#        else
#            sleep 0.5
#            echo -n .
#        fi
#    done
#fi

### initialize movim
php vendor/bin/phinx migrate

php-fpm --daemonize

sleep 5

exec "$@"
