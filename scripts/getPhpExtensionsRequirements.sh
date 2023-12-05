#!/usr/bin/env bash
set -e

PROJECT_PATH=$1
COMPOSER_IMAGE="composer:2"
PHP_IMAGE_FROM="php:8.2.12-fpm-bookworm"

[ -f .env ] && source .env

if [ -z "$PROJECT_PATH" ]; then
    echo "Usage: $0 <absolute project_path>"
    exit 1
fi


# install project no-dev dependencies
docker run --rm -v "$PROJECT_PATH":/app -w /app $COMPOSER_IMAGE install --no-dev --no-interaction --no-progress --no-scripts --prefer-dist --ignore-platform-reqs

# get required extensions from composer
REQUIRED=$(docker run --rm -v "$PROJECT_PATH":/app -w /app $COMPOSER_IMAGE composer show --tree | grep -o "ext-.* " | sort | uniq )

# get existing extensions from php image
LOADED=$(docker run --rm $PHP_IMAGE_FROM php -r "print_r(implode(PHP_EOL,get_loaded_extensions()));")

MISSING=()

while read -r line; do
  if ! grep -q -i "${line:4}" <<< "$LOADED"; then
    MISSING+=("$line")
  fi
done <<< "$REQUIRED"

echo "Missing extensions:"
printf '%s\n' "${MISSING[@]}"
