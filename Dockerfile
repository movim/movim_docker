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
	docker-php-ext-install gd pdo_pgsql pgsql zip; \
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

VOLUME /var/www/html

ARG MOVIM_VERSION=0.21rc11 \
		MOVIM_SHA512=9b7ffc60b3f2b9fdfb740df449e86dee29b04576e0c19bae2ea4558f7286622a27cd957a32dbc71636a51d6a5ec6536003854307b5787b794e6f6dfa3eeb66c2

ENV MOVIM_VERSION=${MOVIM_VERSION} \
		MOVIM_SHA512=${MOVIM_SHA512}

RUN set -ex; \
        if [ "$MOVIM_VERSION" = "master" ]; then \
                curl -Lo movim-$MOVIM_VERSION.zip https://github.com/movim/movim/archive/refs/heads/master.zip; \
								unzip -d /usr/src/ movim-$MOVIM_VERSION.zip; \
								chown -R www-data:www-data /usr/src/movim-${MOVIM_VERSION};\
        else \
                curl -o movim.tar.gz -fSL "https://github.com/movim/movim/archive/v${MOVIM_VERSION}.tar.gz"; \
                echo "$MOVIM_SHA512 *movim.tar.gz" | sha512sum -c -; \
                tar -xzf movim.tar.gz -C /usr/src/; \
                rm movim.tar.gz; \
								chown -R www-data:www-data /usr/src/movim-${MOVIM_VERSION};\
        fi

RUN cd /usr/src/movim-${MOVIM_VERSION} && \
		curl -sS https://getcomposer.org/installer | php \
    && php composer.phar install --optimize-autoloader
		

WORKDIR /var/www/html

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["su", "-s", "/bin/sh", "-c", "php daemon.php start", "www-data"]
