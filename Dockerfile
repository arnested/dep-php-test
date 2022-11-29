## Helper images
FROM blackfire/blackfire:2@sha256:17066fd70dc5239540fe33b938aa594e2cff21990340bd0eeec323d52e30d6e4 AS blackfire
FROM composer:2@sha256:2ba38126efbed61e8e888669c68b7055e64e30afdd5d9f984fa65ec19d076c1e AS composer
FROM mlocati/php-extension-installer:1@sha256:d74d9120fd52521195f7182417e25ece84b34e4e6d518914ce6f105698ac4ba0 AS php-extension-installer

## Custom PHP image
# hadolint ignore=DL3006
FROM reload-php

ARG php_enable_extensions="bcmath calendar ctype curl dom exif fileinfo ftp gd gettext iconv imagick intl json mbstring memcache memcached mysqli mysqlnd opcache pdo pdo_mysql pdo_sqlite phar posix readline redis shmop simplexml soap sockets sqlite3 sysvmsg sysvsem sysvshm tokenizer xml xmlreader xmlwriter xsl zip"
ARG php_install_extensions="xdebug"

HEALTHCHECK CMD netstat -ltn | grep -c ":9000"

COPY context/ /

COPY --from=blackfire /usr/local/bin/blackfire /usr/bin
COPY --from=composer /usr/bin/composer /usr/bin
COPY --from=php-extension-installer /usr/bin/install-php-extensions /usr/bin

RUN apk add --no-cache bash=~5 git=~2 mariadb-client=~10 msmtp=~1 patch=~2 unzip=~6 && \
    install-php-extensions ${php_enable_extensions} && \
    IPE_DONT_ENABLE=1 install-php-extensions ${php_install_extensions}

ENV PHP_SENDMAIL_PATH="/usr/bin/msmtp --read-recipients"

ENTRYPOINT [ "reload-php-entrypoint" ]
CMD [ "php-fpm" ]
