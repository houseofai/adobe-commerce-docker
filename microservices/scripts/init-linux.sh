#!/bin/bash

install() {
  echo "Install php 7.4"
  sudo apt-get update && sudo apt-get install php
}

start_clean() {
  sudo rm -rf $1
}

is_docker_stopped() {
  return ! sudo docker info >/dev/null 2>&1;
}

start_magento() {
  sudo docker-compose up -d

  # Enable all modules (and cleared all generated classes)
  #sudo docker-compose run --rm deploy magento-command module:enable --all --clear-static-content
  #./bin/magento module:enable --all --clear-static-content

  # Disable Two Factor Authentication for easier authentication
  #sudo docker-compose run --rm deploy magento-command module:disable Magento_TwoFactorAuth --clear-static-content
  #./bin/magento module:disable Magento_TwoFactorAuth

  # Deploy Magento
  sudo docker-compose run --rm deploy cloud-deploy
  #bin/magento config:set system/full_page_cache/caching_application 2
  #bin/magento setup:config:set --http-cache-hosts=varnish -n
  #php ./vendor/bin/ece-tools run scenario/build/generate.xml
  #php ./vendor/bin/ece-tools run scenario/build/transfer.xml
  #php ./vendor/bin/ece-tools run scenario/deploy.xml
  #php ./vendor/bin/ece-tools run scenario/post-deploy.xml
  # 'mounts': {'var': {'path': 'var'}, 'app-etc': {'path': 'app/etc'}, 'pub-media': {'path': 'pub/media'}, 'pub-static': {'path': 'pub/static'}}

  # Deploy sample data (takes couple of minutes)
  sudo docker-compose run --rm deploy magento-command sampledata:deploy
  #bin/magento sampledata:deploy

  # Upgrade Magento installation
  sudo docker-compose run --rm deploy magento-command setup:upgrade
  #bin/magento setup:upgrade

  # Compile classes
  sudo docker-compose run --rm deploy magento-command setup:di:compile
  #bin/magento setup:di:compile

  # Flush cache
  sudo docker-compose run --rm deploy magento-command cache:clean
  #bin/magento  cache:clean

  # Stop all containers
  sudo docker-compose stop
}
