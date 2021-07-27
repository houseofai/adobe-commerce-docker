#!/bin/bash

ROOT_DIR=$(pwd)
CONFIG_DIR=$ROOT_DIR/config

MAGENTO_EDITION=enterprise
#MAGENTO_EDITION=community
MAGENTO_BASE_DIR=magento
MAGENTO_COMPOSER_AUTH_FILE=auth.json
MAGENTO_COMPOSER_FILE=composer.json

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi


if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  echo "~ Linux install script ~ "
  . "$DIR/scripts/init-linux.sh"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  echo "~ Darwin install script ~ "
  . "$DIR/scripts/init-darwin.sh"
else
  echo "Unsupported OS Type [$OSTYPE]"
  exit 1
fi

# Run the install script
install
# Clean current folder
start_clean $MAGENTO_BASE_DIR

# Check if docker is running
if is_docker_stopped; then
    echo "Docker does not seem to be running, run it first and retry"
    exit 1
fi

# Check for Composer tool
if ! command -v composer &> /dev/null
then
  php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
  php -r "if (hash_file('sha384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
  sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
  php -r "unlink('composer-setup.php');"
fi

# Check for Composer authentication file
if [ ! -f $MAGENTO_COMPOSER_AUTH_FILE ]; then
    echo "Composer authentication file $MAGENTO_COMPOSER_AUTH_FILE not found in $CONFIG_DIR!"
    exit 1
fi

set -ex

# Create a project from a template
composer create-project --repository-url=https://repo.magento.com/ magento/project-$MAGENTO_EDITION-edition $MAGENTO_BASE_DIR

# Switch to the magento project directory
cd $MAGENTO_BASE_DIR

# Copy the Composer authentication file
cp $MAGENTO_COMPOSER_AUTH_FILE .

# Import all vendors packages
composer require --no-update --dev magento/ece-tools magento/magento-cloud-docker

# @FIX
composer require --no-update --dev symfony/console=4.4.26
# Creates the ece-docker tool
composer update

cp $CONFIG_DIR/.magento.docker.yml .
./vendor/bin/ece-docker build:compose --mode="developer"

cp $CONFIG_DIR/config.env .docker/
cp $CONFIG_DIR/docker-compose.yml .

./bin/magento module:enable --all --clear-static-content
./bin/magento module:disable Magento_TwoFactorAuth --clear-static-content

#Start all containers
start_magento
