FROM php:7.2-fpm
MAINTAINER Kane Valentine <kane@cute.im>

RUN set -ex; \
	\
	apt-get update; \
	apt-get install -y --no-install-suggests --no-install-recommends \
		libjpeg-dev \
		libpng-dev \
		libzmq3-dev \
		libpq-dev \
	; \
	apt-get clean; \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*; \
	\
	docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
	docker-php-ext-install gd pgsql; \
	\
	pecl install zmq-beta; \
	docker-php-ext-enable zmq