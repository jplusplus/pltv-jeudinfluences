FROM php:7-apache-buster

# Copy Node binaries                                                                                                                                                                                             
COPY --from=node:10-buster /usr/lib /usr/lib                                                                                                                                                                                 
COPY --from=node:10-buster /usr/local/share /usr/local/share                                                                                                                                                                 
COPY --from=node:10-buster /usr/local/lib /usr/local/lib                                                                                                                                                                     
COPY --from=node:10-buster /usr/local/include /usr/local/include                                                                                                                                                             
COPY --from=node:10-buster /usr/local/bin /usr/local/bin                                                                                                                                                                     
COPY --from=node:10-buster /opt/ /opt/  

# Copy Composer binary
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Add missing packages
RUN apt update && \
  apt install -y zlib1g-dev g++ git libicu-dev zip libzip-dev zip libpq-dev \
  && docker-php-ext-install mysqli pdo pdo_mysql \
  && docker-php-ext-enable pdo_mysql \
  && pecl install apcu \
  && docker-php-ext-enable apcu \
  && docker-php-ext-configure zip \
  && docker-php-ext-install zip

COPY apache.conf /etc/apache2/sites-available/000-default.conf
COPY start-apache /usr/local/bin

RUN chmod 755 /usr/local/bin/start-apache
RUN a2enmod rewrite

WORKDIR /var/www/ 

COPY package.json yarn.lock ./
RUN yarn --non-interactive

COPY composer.json composer.lock ./
RUN composer install

COPY . /var/www/
RUN chown -R www-data:www-data /var/www
RUN npx grunt production dist
RUN chmod -Rf 777 ./dist/tmp

CMD ["start-apache"]