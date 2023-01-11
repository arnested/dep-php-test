# Docker PHP FPM images for development use

This is a PHP FPM Docker image tuned to be used in Docker Compose
setups for devlopment environments.

We have tried to hit a sweet stuff between not doing too much magic,
but still be an easy fit for how we do work at [Reload
A/S](https://reload.dk).

A simple example of usage would be having a `php` service providing
FPM like this:

```yaml
services:
  php:
    image: 'ghcr.io/reload/php-fpm:8.2'
    ports:
      - '9000'
    user: '${UID:-501}:${GID:-20}'
    volumes:
      - .:/var/www'
    environment:
      USE_FEATURES: >-
        root-php-ini
 ```

## PHP versions

We provide PHP 8.0, 8.1, and 8.2 images.

PHP 7.x versions are no longer supported upstream so we won't provide
them either.

The images are based on the official [`php:8.x-fpm-alpine` Docker
images](https://hub.docker.com/_/php). We build new images when new
upstream versions are released.

The image has some PHP settings set for devlopment / debuging use, see
[`debug.ini`](/blob/main/context/usr/local/etc/php/conf.d/debug.ini). They
can be disabled with `no-debug` feature mentioned later in this
document.

## User

The images are designed to be able to run as root inside the container
or as uid `501` (MacOS typical user ID) or uid `1000` (Linux typical
user ID). Other user ID's might work as well.

This being an image for development use we have installed `sudo` and
configured all users in the container to use it without providing a
password.

## Volumes

We recommend mounting the project root of your repository into the
Docker workdir, `/var/www`.

## PHP Document root

FPM exptects PHP's document root to be located in `/var/www/web`. That
would be a `web` folder inside your project root if you follow our
practice.

If you would like the document root to be located elsewhere you should
set the environment variable `PHP_DOCUMENT_ROOT` to the desired
location.

## PHP extensions

The images come with the following tools installed and enable:

- bcmath
- calendar
- ctype
- curl
- dom
- exif
- fileinfo
- ftp
- gd
- gettext
- iconv
- imagick
- intl
- json
- mbstring
- memcache
- memcached
- mysqli
- mysqlnd
- opcache
- pdo
- pdo_mysql
- pdo_sqlite
- phar
- posix
- readline
- redis
- shmop
- simplexml
- soap
- sockets
- sqlite3
- sysvmsg
- sysvsem
- sysvshm
- tokenizer
- xml
- xmlreader
- xmlwriter
- xsl
- zip

In addtion the `xdebug` and `blackfire` extensions are installed but
not enabled in the images.

The
[php-extension-installer](https://github.com/mlocati/docker-php-extension-installer)
tool is installed if you want to install addtional extensions your self.

## Entrypoint scripts

If you place executables (e.g. by mounting them there) in
`/etc/entrypoint.d` they will be run prior to starting FPM.

## "Features"

The images come with a concept called "features".

Features a predefined entrypoint scripts with common functionality you
can opt-in to using.

Features a run prior to the entrypoint scripts mentioned before.

You opt-in to using them by setting the `USE_FEATURES` to a space
separated list of their names.

### `install-composer-extensions` feature

If you have a `composer.json` in your workdir (`/var/www`) this
feature will locate requied depenencies on PHP extensions `ext-*` and
install them using the aforementioned `php-extension-installer` tool.

Notice: if this needs to install a lot of libraries and do a lot
compilation this could take quite some time when creating the container.

### `root-php-ini` feature

If you have a `php.ini` in your workdir (`/var/www`) this will be
loaded by FPM.

### `no-debug` feature

Disable the PHP ini settings in
[`debug.ini`](/blob/main/context/usr/local/etc/php/conf.d/debug.ini).

## Xdebug

@todo

## Blackfire

@todo

## Mail

@todo

## TODO

- [x] Make sure @dependabot can keep the various PHP versions up to date
- [ ] Documentation on how to use
- [ ] Documentation on the philosophie behind the images
- [ ] Documentation on how to migrate from [old Reload images](https://github.com/reload/docker-drupal-php7-fpm)
- [x] Find better way to determine document root
- [x] Drupal specific configuration (I know how I want this done)
- [x] Blackfire integration
- [x] Xdebug integration
- [x] Run goss test on GitHub CI
