FROM debian:stretch-slim
ENV DEBIAN_FRONTEND noninteractive

MAINTAINER Kane Valentine - OpusVL <kane.valentine@opusvl.com>

RUN apt-get update \
    && apt-get --no-install-suggests --no-install-recommends \
       install -y git curl wget unzip php7.0-fpm \
       php7.0-cli php7.0-mcrypt php7.0-gd php7.0-imagick php7.0-pgsql \
       php7.0-mbstring php7.0-xml php7.0-curl php-zmq ca-certificates \
    && mkdir /run/php \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD config/php-fpm.conf /etc/php/7.0/fpm/php-fpm.conf
ADD config/www.conf /etc/php/7.0/fpm/pool.d/www.conf
ADD config/php-cli.ini /etc/php/7.0/cli/php.ini

RUN git clone https://github.com/movim/movim.git /var/www/movim/

RUN chown -R www-data: /var/www \
    && chmod -R u+rwX /var/www

WORKDIR /var/www/movim/
USER www-data

RUN curl -sS https://getcomposer.org/installer | php \
    && php composer.phar install

USER root

ADD config/ /opt/config/
ADD scripts/ /opt/scripts/

ENTRYPOINT ["/opt/scripts/init.sh"]
