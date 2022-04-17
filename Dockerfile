# Specify the version of PHP and Chevereto we use for our Chevereto
ARG PHP_VERSION
ARG CHEVERETO_VERSION

# Run composer
FROM composer AS composer

ARG CHEVERETO_VERSION
COPY app/chevereto-free-${CHEVERETO_VERSION}/ /app/
RUN composer install \
    --working-dir=/app/ \
    --prefer-dist \
    --no-progress \
    --classmap-authoritative \
    --ignore-platform-reqs

FROM php:$PHP_VERSION

# Install required packages and configure plugins + mods for Chevereto
RUN apt-get update && apt-get install -y \
        libgd-dev \
        libzip-dev && \
    bash -c 'if [[ $PHP_VERSION == 7.4.* ]]; then \
      docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/; \
    else \
      docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/; \
    fi' && \
    docker-php-ext-install \
        exif \
        gd \
        mysqli \
        pdo \
        pdo_mysql \
        zip && \
    a2enmod rewrite

# Download installer script
COPY --from=composer --chown=33:33 /app/ /var/www/html

# Expose the image directory as a volume
VOLUME /var/www/html/images

# Some default env-var, user is supposed to follow instruction and provide necessary values
ARG BUILD_DATE
ARG CHEVERETO_VERSION
ENV CHEVERETO_DB_DRIVER=mysql CHEVERETO_DB_PREFIX=chv_ CHEVERETO_DB_PORT=3306 CHEVERETO_SERVICING=docker CHEVERETO_VERSION=$CHEVERETO_VERSION

# Set all required labels, we set it here to make sure the file is as reusable as possible
LABEL org.label-schema.url="https://github.com/tanmng/docker-chevereto" \
      org.label-schema.name="Chevereto Free" \
      org.label-schema.license="Apache-2.0" \
      org.label-schema.version="${CHEVERETO_VERSION}" \
      org.label-schema.vcs-url="https://github.com/tanmng/docker-chevereto" \
      maintainer="Tan Nguyen <tan.mng90@gmail.com>" \
      build_signature="Chevereto free version ${CHEVERETO_VERSION}; built on ${BUILD_DATE}; Using PHP version ${PHP_VERSION}"
      
ENTRYPOINT ["/var/www/html/custom-entrypoint.sh"]
