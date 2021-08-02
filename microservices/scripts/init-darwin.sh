#!/bin/bash

install() {
  brew update
  echo "Install php 7.4"
  brew install php@7.4
  brew link php@7.4
}

start_clean() {
  rm -rf $1
}

is_docker_stopped() {
  return ! docker info >/dev/null 2>&1;
}

start_magento() {
  docker-compose up -d

  # Enable all modules (and cleared all generated classes)
  #docker-compose run --rm deploy magento-command module:enable --all --clear-static-content
  #./bin/magento module:enable --all --clear-static-content

  # Disable Two Factor Authentication for easier authentication
  #docker-compose run --rm deploy magento-command module:disable Magento_TwoFactorAuth
  #./bin/magento module:disable Magento_TwoFactorAuth

  # Deploy Magento
  docker-compose run --rm deploy cloud-deploy
  #bin/magento config:set system/full_page_cache/caching_application 2
  #bin/magento setup:config:set --http-cache-hosts=varnish -n
  #php ./vendor/bin/ece-tools run scenario/build/generate.xml
  #php ./vendor/bin/ece-tools run scenario/build/transfer.xml
  #php ./vendor/bin/ece-tools run scenario/deploy.xml
  #php ./vendor/bin/ece-tools run scenario/post-deploy.xml
  # 'mounts': {'var': {'path': 'var'}, 'app-etc': {'path': 'app/etc'}, 'pub-media': {'path': 'pub/media'}, 'pub-static': {'path': 'pub/static'}}

  # Deploy sample data (takes couple of minutes)
  docker-compose run --rm deploy magento-command sampledata:deploy
  #bin/magento sampledata:deploy

  # Upgrade Magento installation
  docker-compose run --rm deploy magento-command setup:upgrade
  #bin/magento setup:upgrade

  # Compile classes
  docker-compose run --rm deploy magento-command setup:di:compile
  #bin/magento setup:di:compile

  # Flush cache
  docker-compose run --rm deploy magento-command cache:clean
  #bin/magento cache:clean

  # Stop all containers
  docker-compose stop
}
