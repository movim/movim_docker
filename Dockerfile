FROM php:7.2-fpm

LABEL vendor="The Movim Team"
LABEL version="0.13"
LABEL maintainer="Kane Valentine <kane@cute.im>"

RUN set -ex; \
	\
	apt-get update; \
	apt-get install -y --no-install-suggests --no-install-recommends \
		git \
	; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	\
	apt-get install -y --no-install-suggests --no-install-recommends \
		libmagickwand-dev \
		libjpeg-dev \
		libpng-dev \
		libzmq3-dev \
		libpq-dev \
	; \
	\
	docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
	docker-php-ext-install gd pdo_pgsql pgsql zip; \
	\
	pecl install imagick-3.4.3 zmq-beta; \
	docker-php-ext-enable imagick zmq; \
	\
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark; \
	ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
		| awk '/=>/ { print $3 }' \
		| sort -u \
		| xargs -r dpkg-query -S \
		| cut -d: -f1 \
		| sort -u \
		| xargs -rt apt-mark manual; \
	\
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*

VOLUME /var/www/html

ENV MOVIM_VERSION 0.13
ENV MOVIM_SHA1 dfc083bb3d94549e162da451e883ec1e8889905d

RUN set -ex; \
	curl -o movim.tar.gz -fSL "https://github.com/movim/movim/archive/v${MOVIM_VERSION}.tar.gz"; \
	echo "$MOVIM_SHA1 *movim.tar.gz" | sha1sum -c -; \
	tar -xzf movim.tar.gz -C /usr/src/; \
	rm movim.tar.gz; \
	chown -R www-data:www-data /usr/src/movim-${MOVIM_VERSION}

WORKDIR /usr/src/movim-${MOVIM_VERSION}

RUN curl -sS https://getcomposer.org/installer | php \
    && php composer.phar install --no-suggest --optimize-autoloader

WORKDIR /var/www/html

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["su", "-s", "/bin/sh", "-c", "php daemon.php start --url=$MOVIM_DOMAIN --port=$MOVIM_PORT --interface=$MOVIM_INTERFACE --verbose --debug", "www-data"]
