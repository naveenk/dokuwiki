FROM ubuntu:14.04
MAINTAINER Naveen Koorakula <naveenk@gmail.com>

RUN apt-get update && \
    apt-get install -y nginx php5-fpm php5-gd curl unzip && \
    rm -rf /var/lib/apt/lists/*

# Download and set up dokuwiki
RUN mkdir -p /var/www/dokuwiki
RUN cd /var/www/dokuwiki && curl http://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz | tar xz --strip 1

# Set up dokuwiki farm (https://www.dokuwiki.org/farms)
RUN mkdir -p /var/www/farm
RUN cp /var/www/dokuwiki/inc/preload.php.dist /var/www/dokuwiki/inc/preload.php
RUN sed -i "s/\/\/if(\!defined('DOKU_FARMDIR/if(\!defined('DOKU_FARMDIR/" /var/www/dokuwiki/inc/preload.php
RUN sed -i "s/\/\/include(fullpath(dirname/include(fullpath(dirname/" /var/www/dokuwiki/inc/preload.php
RUN cd /var/www/farm && curl -s https://www.dokuwiki.org/_media/dokuwiki_farm_animal.zip -o farm_animal.zip
RUN cd /var/www/farm && unzip farm_animal.zip

# Different wikis we want in the farm
RUN cd /var/www/farm && cp -rp _animal base.nfx.com
RUN cd /var/www/farm && cp -rp _animal know.blue.com
RUN cd /var/www/farm && cp -rp _animal whatshouldwelearn.org

RUN chown -R www-data:www-data /var/www

RUN echo "cgi.fix_pathinfo = 0;" >> /etc/php5/fpm/php.ini
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN rm /etc/nginx/sites-enabled/*
ADD dokuwiki.conf /etc/nginx/sites-enabled/

EXPOSE 80
VOLUME [ \
    "/var/www/farm/base.nfx.com/data/pages", \
    "/var/www/farm/base.nfx.com/data/meta", \
    "/var/www/farm/base.nfx.com/data/media", \
    "/var/www/farm/base.nfx.com/data/media_attic", \
    "/var/www/farm/base.nfx.com/data/media_meta", \
    "/var/www/farm/base.nfx.com/data/attic", \
    "/var/www/farm/base.nfx.com/conf", \
    "/var/www/farm/know.blue.com/data/pages", \
    "/var/www/farm/know.blue.com/data/meta", \
    "/var/www/farm/know.blue.com/data/media", \
    "/var/www/farm/know.blue.com/data/media_attic", \
    "/var/www/farm/know.blue.com/data/media_meta", \
    "/var/www/farm/know.blue.com/data/attic", \
    "/var/www/farm/know.blue.com/conf", \
    "/var/www/farm/whatshouldwelearn.org/data/pages", \
    "/var/www/farm/whatshouldwelearn.org/data/meta", \
    "/var/www/farm/whatshouldwelearn.org/data/media", \
    "/var/www/farm/whatshouldwelearn.org/data/media_attic", \
    "/var/www/farm/whatshouldwelearn.org/data/media_meta", \
    "/var/www/farm/whatshouldwelearn.org/data/attic", \
    "/var/www/farm/whatshouldwelearn.org/conf", \
    "/var/log" \
]

CMD /usr/sbin/php5-fpm && /usr/sbin/nginx
