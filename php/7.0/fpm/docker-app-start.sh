#!/bin/sh
set -xe

export DOCKER_BRIDGE_IP=$(ip ro | grep default | cut -d' ' -f 3)

# Blackfire
if [ ${PHP_BLACKFIRE_ENABLED} -eq 1 ] ; then
printf "
extension=blackfire.so
blackfire.agent_socket = tcp://${PHP_BLACKFIRE_HOST}:${PHP_BLACKFIRE_PORT}
" > /usr/local/etc/php/conf.d/docker-php-ext-blackfire.ini
else
printf "
;extension=blackfire.so
" > /usr/local/etc/php/conf.d/docker-php-ext-blackfire.ini
fi

# Xdebug
if [ ${PHP_XDEBUG_ENABLED} -eq 1 ] ; then
if [ ! ${PHP_XDEBUG_HOST} ]; then
    PHP_XDEBUG_HOST=${DOCKER_BRIDGE_IP}
fi
printf "
zend_extension=xdebug.so
xdebug.default_enable = ${PHP_XDEBUG_ENABLED}\n
xdebug.remote_enable = e${PHP_XDEBUG_ENABLED}\n
xdebug.remote_host = ${PHP_XDEBUG_HOST}\n
xdebug.remote_port = ${PHP_XDEBUG_PORT}\n
xdebug.remote_handler = dbgp\n
xdebug.remote_autostart = ${PHP_XDEBUG_ENABLED}\n
xdebug.max_nesting_level = ${PHP_XDEBUG_MAX_NESTING_LEVEL}\n
xdebug.idekey = ${PHP_XDEBUG_IDEKEY}
" > /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
else
printf "
;zend_extension=xdebug.so
" > /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
fi

# Give rights for cache & logs (sf1 & sf2 & sf3)
chown -R www-data:www-data var var/cache var/logs var/sessions app/cache app/logs cache log || true

# Launch
if [ "$#" -ge 1 ]; then
    exec "$@"
else
    # Infinite loop
    exec php-fpm
fi
