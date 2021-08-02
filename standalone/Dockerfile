FROM ubuntu

ARG DEBIAN_FRONTEND=noninteractive
ARG PHP_VERSION=7.4
ARG NGINX=stable
#ARG mode=enterprise
ARG mode=community

ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE 1
ENV MAGENTO_ROOT /var/www/html
ENV MAGENTO_DIR magento2
ENV DB_NAME magento
ENV DB_USER magento
ENV DB_PASSWORD magento
ENV MAGENTO_USER admin
ENV MAGENTO_PASSWORD 123123q

# Install PHP extensions
ENV PHP_EXTENSIONS php$PHP_VERSION-fpm \
  php$PHP_VERSION-cli \
  php$PHP_VERSION-bcmath \
  php$PHP_VERSION-bz2 \
  php$PHP_VERSION-calendar \
  php$PHP_VERSION-curl \
  php$PHP_VERSION-exif \
  php$PHP_VERSION-gd \
  php$PHP_VERSION-gettext \
  php$PHP_VERSION-gmp \
  php$PHP_VERSION-intl \
  php$PHP_VERSION-ldap \
  php$PHP_VERSION-mysqli \
  php$PHP_VERSION-opcache \
  php$PHP_VERSION-mysql \
  php$PHP_VERSION-mbstring \
  php$PHP_VERSION-pspell \
  php$PHP_VERSION-shmop \
  php$PHP_VERSION-soap \
  php$PHP_VERSION-sockets \
  php$PHP_VERSION-sysvmsg \
  php$PHP_VERSION-sysvsem \
  php$PHP_VERSION-sysvshm \
  php$PHP_VERSION-tidy \
  php$PHP_VERSION-xsl \
  php$PHP_VERSION-zip
  #      php$PHP_VERSION-pcntl

# Install basic tools
RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y --no-install-recommends \
  apt-utils \
  software-properties-common \
  git \
  unzip \
  gpg-agent \
  curl \
  wget

# Install  extra repositories
RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add - \
  && echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" >> /etc/apt/sources.list.d/elastic-7.x.list \
  && add-apt-repository ppa:ondrej/php \
  && add-apt-repository ppa:nginx/$NGINX \
  && apt-get install -y \
  $PHP_EXTENSIONS \
  nginx \
  mariadb-server \
  elasticsearch \
  && phpenmod $PHP_EXTENSIONS

####### Install COMPOSER #######
RUN php -r "copy('http://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('sha384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php --install-dir=bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY etc/default /etc/nginx/sites-available/default
COPY etc/magento /etc/nginx/sites-available/magento
RUN ln -s /etc/nginx/sites-available/magento /etc/nginx/sites-enabled
COPY etc/index.php /var/www/html/index.php

####### Install MARIADB #######
RUN service mysql start \
  && mysql -uroot -e "create database $DB_NAME;" \
  && mysql -uroot -e "create user $DB_USER IDENTIFIED BY '$DB_PASSWORD';" \
  && mysql -uroot -e "use $DB_NAME; grant all privileges on $DB_NAME.* to '$DB_USER'@'localhost' identified by '$DB_PASSWORD'; flush privileges;"

####### Install ELASTIC SEARCH #######
RUN echo "vm.max_map_count=262144" >> /etc/sysctl.conf # && sysctl -p /etc/sysctl.conf \
  && chown elasticsearch:elasticsearch -R /usr/share/elasticsearch /var/log/elasticsearch /var/lib/elasticsearch /etc/default/elasticsearch /etc/elasticsearch \
  && service elasticsearch start && service elasticsearch status

####### Install MAGENTO #######
COPY auth.json /root/.config/composer/
RUN cd ${MAGENTO_ROOT} \
  && groupadd -g 1000 www && useradd -g 1000 -u 1000 -d ${MAGENTO_ROOT} -s /bin/bash www \
  && composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition ${MAGENTO_DIR} \
  && cd ${MAGENTO_DIR} \
  && cp /root/.config/composer/auth.json . \
  && find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} + \
  && find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} + \
  && chown -R :www-data . \
  && service elasticsearch start \
  && service mysql start \
  && ./bin/magento setup:install \
    --base-url=http://localhost \
    --db-host=localhost \
    --db-name=$DB_NAME \
    --db-user=$DB_USER \
    --db-password=$DB_PASSWORD \
    --admin-firstname=admin \
    --admin-lastname=admin \
    --admin-email=admin@admin.com \
    --admin-user=$MAGENTO_USER \
    --admin-password=$MAGENTO_PASSWORD \
    --language=en_US \
    --currency=USD \
    --timezone=America/Chicago \
    --use-rewrites=1 \
    --backend-frontname=admin \
  && ./bin/magento module:enable --all --clear-static-content \
  && ./bin/magento module:disable Magento_TwoFactorAuth --clear-static-content \
  && ./bin/magento setup:upgrade \
  && ./bin/magento setup:di:compile \
  && ./bin/magento cache:clean \
  && rm ./auth.json \
  && rm /root/.config/composer/auth.json

RUN ["chmod", "+x", "/docker-entrypoint.sh"]
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 80
