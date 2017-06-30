FROM debian:9
ENV DEBIAN_FRONTEND noninteractive

MAINTAINER Kane Valentine - OpusVL <kane.valentine@opusvl.com>

RUN apt-get update && apt-get install -y nginx git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && echo "daemon off;" >> /etc/nginx/nginx.conf

ADD config/default /etc/nginx/sites-available/default
ADD init.sh /init.sh

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

RUN chown -R www-data: /var/www/
RUN chmod -R u+rwx /var/www/

ENTRYPOINT ["/init.sh"]
CMD ["nginx"]
