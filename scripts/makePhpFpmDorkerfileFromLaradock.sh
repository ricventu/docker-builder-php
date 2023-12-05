#!/usr/bin/env bash
set -e

DEST_PATH=$1
LARADOCK_PHP_VERSION="8.2"
PHP_IMAGE_FROM="php:8.2.12-fpm-bookworm"

[ -f .env ] && source .env
[ ! -d "$DEST_PATH" ] && echo "Usage: $0 <path to output directory>" && exit 1


echo "# https://raw.githubusercontent.com/laradock/php-fpm/master/Dockerfile-$LARADOCK_PHP_VERSION" > "$DEST_PATH/Dockerfile"
echo "" >> "$DEST_PATH/Dockerfile"
curl https://raw.githubusercontent.com/laradock/php-fpm/master/Dockerfile-$LARADOCK_PHP_VERSION >> "$DEST_PATH/Dockerfile"
echo "" >> "$DEST_PATH/Dockerfile"
echo "################" >> "$DEST_PATH/Dockerfile"
echo "" >> "$DEST_PATH/Dockerfile"
sed -i -e "s/^FROM php:.*/FROM ${PHP_IMAGE_FROM}/" "$DEST_PATH/Dockerfile"

echo "# https://raw.githubusercontent.com/laradock/laradock/master/php-fpm/Dockerfile" >> "$DEST_PATH/Dockerfile"
echo "" >> "$DEST_PATH/Dockerfile"
curl https://raw.githubusercontent.com/laradock/laradock/master/php-fpm/Dockerfile >> "$DEST_PATH/Dockerfile"
sed -i -e "/^FROM laradock/ s/./#&/" "$DEST_PATH/Dockerfile"
sed -i -e "s/^ARG LARADOCK_PHP_VERSION.*/ARG LARADOCK_PHP_VERSION=${LARADOCK_PHP_VERSION}/" "$DEST_PATH/Dockerfile"

curl https://raw.githubusercontent.com/laradock/laradock/master/php-fpm/opcache.ini > "$DEST_PATH/opcache.ini"
curl https://raw.githubusercontent.com/laradock/laradock/master/php-fpm/laravel.ini > "$DEST_PATH/laravel.ini"
curl https://raw.githubusercontent.com/laradock/laradock/master/php-fpm/xlaravel.pool.conf > "$DEST_PATH/xlaravel.pool.conf"
curl https://raw.githubusercontent.com/laradock/laradock/master/php-fpm/xdebug.ini > "$DEST_PATH/xdebug.ini"


