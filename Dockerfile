FROM php:8.1-fpm

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
	docker-php-ext-install gd opcache pdo_pgsql pgsql zip; \
	\
	pecl install imagick-3.7.0; \
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

RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

VOLUME /var/www/html

ARG MOVIM_VERSION=0.21.1
ARG MOVIM_SHA512=53996bb9148edaf0a1c7de1bef3dc9bee1b46105f21a00fc53432a4fdc201914a1e4c58ca90af27f94edab9829b8b424b45cb41ee85815a0a8541cae190ee44d

ENV MOVIM_VERSION=${MOVIM_VERSION}

RUN set -ex; \
    if [ "$MOVIM_VERSION" = "master" ]; then \
        curl -Lo movim-$MOVIM_VERSION.zip https://github.com/movim/movim/archive/refs/heads/master.zip; \
        unzip -d /usr/src/ movim-$MOVIM_VERSION.zip; \
    else \
        curl -o movim.tar.gz -fSL "https://github.com/movim/movim/archive/v${MOVIM_VERSION}.tar.gz"; \
        echo "${MOVIM_SHA512} *movim.tar.gz" | sha512sum -c -; \
        tar -xzf movim.tar.gz -C /usr/src/; \
        rm movim.tar.gz; \
    fi; \
    chown -R www-data:www-data /usr/src/movim-${MOVIM_VERSION}


RUN cd /usr/src/movim-${MOVIM_VERSION} && \
	curl -sS https://getcomposer.org/installer | php \
	&& php composer.phar install --optimize-autoloader
		

WORKDIR /var/www/html

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["su", "-s", "/bin/sh", "-c", "php daemon.php start", "www-data"]
