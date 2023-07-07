FROM php:8.2-fpm

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
	rm -r /tmp/pear; \
	\
	out="$(php -r 'exit(0);')"; \
	[ -z "$out" ]; \
	err="$(php -r 'exit(0);' 3>&1 1>&2 2>&3)"; \
	[ -z "$err" ]; \
	\
	extDir="$(php -r 'echo ini_get("extension_dir");')"; \
	[ -d "$extDir" ]; \
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark; \
	ldd "$extDir"/*.so \
		| awk '/=>/ { so = $(NF-1); if (index(so, "/usr/local/") == 1) { next }; gsub("^/(usr/)?", "", so); print so }' \
		| sort -u \
		| xargs -r dpkg-query --search \
		| cut -d: -f1 \
		| sort -u \
		| xargs -rt apt-mark manual; \
	\
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*; \
	\
	! { ldd "$extDir"/*.so | grep 'not found'; }; \
	err="$(php --version 3>&1 1>&2 2>&3)"; \
	[ -z "$err" ]

RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

VOLUME /var/www/html

ARG MOVIM_VERSION=0.22
ARG MOVIM_SHA512=42b310fcd9fab2390cbf9ab9f976ab14ec758194743ff716d62b5f5ac0a9ee87ff21bfa61b9cfcc0db650c63add7c914ffee6de8c06a8ff27d0290b9c89cce32

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
