FROM php:7.1.3-apache
MAINTAINER "Manh Tan Nguyen <tan.mng90@gmail.com>"

ENV CHEVERETO_APACHE_RUN_USER www-data
ENV CHEVERETO_APACHE_RUN_GROUP www-data

# DB connection environment variables
ENV CHEVERETO_DB_HOST db
ENV CHEVERETO_DB_USERNAME chevereto
ENV CHEVERETO_DB_PASSWORD chevereto
ENV CHEVERETO_DB_NAME chevereto
ENV CHEVERETO_DB_PREFIX chv_

ENV CHEVERETO_CLONE_DIR /opt/chevereto

# Install required packages
RUN apt-get update && apt-get install -y \
        git \
        libgd-dev

# Install php extensions that we need for Chevereto and its installer
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-install \
    gd \
    mysqli \
    pdo \
    pdo_mysql
 
# Enable mod_rewrite for Chevereto
RUN a2enmod rewrite

# Set all required labels, we set it here to make sure the file is as reusable as possible
LABEL org.label-schema.url="https://github.com/tanmng/docker-chevereto" \
      org.label-schema.name="Chevereto Free" \
      org.label-schema.license="Apache-2.0" \
      org.label-schema.version="Latest" \
      org.label-schema.vcs-url="https://github.com/tanmng/docker-chevereto" \
      org.label-schema.schema-version="1.0" \
      com.puppet.dockerfile="/Dockerfile"

# Download installer script
RUN git clone https://github.com/Chevereto/Chevereto-Free.git ${CHEVERETO_CLONE_DIR} \
    && rsync -avip ${CHEVERETO_CLONE_DIR}/ /var/www/html/ \
    && rm -rf ${CHEVERETO_CLONE_DIR}

USER ${CHEVERETO_APACHE_RUN_USER}

COPY settings.php /var/www/html/app/settings.php

# Expose the image directory
VOLUME /var/www/html/images

# Change back to root user for normal Service start up
USER root
