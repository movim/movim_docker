FROM php:7.4-fpm

RUN set -ex; \
	\
	apt-get update; \
	apt-get install -qq --no-install-suggests --no-install-recommends \
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
	docker-php-ext-configure gd --with-jpeg=/usr --with-webp=/usr; \
	docker-php-ext-install gd pdo_pgsql pgsql zip; \
	\
	pecl install imagick-3.5.1; \
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

ENV MOVIM_VERSION 0.20rc1
ENV MOVIM_SHA512 4ef81f83ff7ebc838029e4107e0a191956c86398f7d51f69eb087521103ca2e8c6cf1c516d09415c229c04fa6e97b5e3697acf2d92703b69fdbb0b05d84cff03

RUN set -ex; \
	curl -o movim.tar.gz -fSL "https://github.com/movim/movim/archive/v${MOVIM_VERSION}.tar.gz"; \
	echo "$MOVIM_SHA512 *movim.tar.gz" | sha512sum -c -; \
	tar -xzf movim.tar.gz -C /usr/src/; \
	rm movim.tar.gz; \
	chown -R www-data:www-data /usr/src/movim-${MOVIM_VERSION}

WORKDIR /usr/src/movim-${MOVIM_VERSION}

RUN curl -sS https://getcomposer.org/installer | php \
    && php composer.phar install --optimize-autoloader

WORKDIR /var/www/html

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["su", "-s", "/bin/sh", "-c", "php daemon.php start --url=$MOVIM_DOMAIN --port=$MOVIM_PORT --interface=$MOVIM_INTERFACE --verbose --debug", "www-data"]
