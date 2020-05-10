FROM php:7.3-fpm

RUN set -ex; \
	\
	apt-get update; \
	apt-get install -qq --no-install-suggests --no-install-recommends \
		git \
		unzip \
	; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	\
	apt-get install -qq --no-install-suggests --no-install-recommends \
		libmagickwand-dev \
		libjpeg-dev \
		libpng-dev \
		libwebp-dev \
		libpq-dev \
		libzip-dev \
	; \
	\
	docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr --with-webp-dir=/usr; \
	docker-php-ext-install gd pdo_pgsql pgsql zip; \
	\
	pecl install imagick-3.4.4; \
	docker-php-ext-enable imagick; \
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

ENV MOVIM_VERSION master

RUN set -ex; \
	curl -o movim.zip -fSL "https://github.com/movim/movim/archive/master.zip"; \
	unzip movim.zipre -C /usr/src/; \
	rm movim.zip; \
	chown -R www-data:www-data /usr/src/movim-${MOVIM_VERSION}

WORKDIR /usr/src/movim-${MOVIM_VERSION}

RUN curl -sS https://getcomposer.org/installer | php \
    && php composer.phar install --no-suggest --optimize-autoloader

WORKDIR /var/www/html

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["su", "-s", "/bin/sh", "-c", "php daemon.php start --url=$MOVIM_DOMAIN --port=$MOVIM_PORT --interface=$MOVIM_INTERFACE --verbose --debug", "www-data"]
