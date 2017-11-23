FROM debian:stretch-slim
ENV DEBIAN_FRONTEND noninteractive

MAINTAINER Kane Valentine - OpusVL <kane.valentine@opusvl.com>

RUN apt-get update && apt-get install -y nginx git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && echo "daemon off;" >> /etc/nginx/nginx.conf

ADD config/default /etc/nginx/sites-available/default
ADD scripts/ /opt/scripts/

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

RUN chown -R www-data: /var/www/ \
    && chmod -R u+rwx /var/www/

ENTRYPOINT ["/opt/scripts/init.sh"]
CMD ["nginx"]
