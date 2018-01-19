FROM alpine:3.6

# Repository
RUN echo "http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk update

# Copy data
COPY ./build/etc/php5 /etc/php5

RUN set -ex \
    # Install build-deps
    && apk add --virtual build-dependencies \
        autoconf gcc g++ libffi-dev openssl-dev libmemcached \
        zlib-dev file libc-dev make pkgconf tar tzdata wget \
    # Install common packages
    && apk add sudo git tini openssh-client make mysql-client jq curl bash ca-certificates \
    && apk add supervisor \
    # Build percona
    && apk add percona-toolkit \
    # Install php5
    && apk add php5-dev php5-phar php5-cli php5-bcmath php5-imap php5-curl php5-json php5-mcrypt php5-pdo_mysql \
        php5-opcache php5-soap php5-sqlite3 php5-xml php5-zip php5-openssl php5-phar php5-iconv \
        php5-pdo php5-pdo_sqlite php5-dom php5-sockets php5-ctype php5-zlib php5-pcntl php5-ctype \
    # Fix php bin
    && rm -f /usr/bin/php && ln -s /usr/bin/php5 /usr/bin/php \
    # Build php5-memcached
    && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-php5-memcached/master/sgerrand.rsa.pub \
    && wget https://github.com/sgerrand/alpine-pkg-php5-memcached/releases/download/2.2.0-r0/php5-memcached-2.2.0-r0.apk \
    && apk add php5-memcached-2.2.0-r0.apk \
    && rm php5-memcached-2.2.0-r0.apk \
    # Build php-redis
    && cd /tmp && wget https://github.com/phpredis/phpredis/archive/3.1.2.zip -O phpredis.zip \
    && unzip -o /tmp/phpredis.zip && mv /tmp/phpredis-* /tmp/phpredis \
    && cd /tmp/phpredis && phpize5 && ./configure --with-php-config=/usr/bin/php-config5 \
    && make && make install && echo "extension=redis.so" > /etc/php5/conf.d/redis.ini && rm -rf /tmp/phpredis \
    # Install composer
    && wget https://raw.githubusercontent.com/composer/getcomposer.org/1b137f8bf6db3e79a38a5bc45324414a6b1f9df2/web/installer -O - -q | php -- --quiet --install-dir=/usr/local/bin --filename=composer \
    && echo "export COMPOSER_HOME=/root/.composer" >> ~/.bashrc \
    && composer global require squizlabs/php_codesniffer \
    # Cleanup
    && apk del build-dependencies \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/*
