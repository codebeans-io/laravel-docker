FROM alpine:3.15

# Install packages and remove default server definition
RUN apk --no-cache add \
  curl \
  nginx \
  php8 \
  php8-ctype \
  php8-curl \
  php8-dom \
  php8-fpm \
  php8-gd \
  php8-intl \
  php8-json \
  php8-mbstring \
  php8-mysqli \
  php8-opcache \
  php8-openssl \
  php8-phar \
  php8-session \
  php8-xml \
  php8-xmlreader \
  php8-zlib \
  php8-fileinfo \
  php8-tokenizer \
  php8-xmlwriter \
  supervisor \
  nodejs \
  npm

RUN mkdir -p /npm
RUN chown -R nobody:nobody ./npm

# Create symlink so programs depending on `php` still function
RUN ln -s /usr/bin/php8 /usr/bin/php

# Configure nginx
COPY docker/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY docker/fpm-pool.conf /etc/php8/php-fpm.d/www.conf
COPY docker/php.ini /etc/php8/conf.d/custom.ini

# Configure supervisord
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Setup document root
RUN mkdir -p /var/www/html

WORKDIR /var/www/html
# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
RUN composer create-project laravel/laravel="8.6.*" . && \
    mv .env.example .env && \
    php artisan key:generate

# NPM install
RUN npm install && npm run prod

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R nobody.nobody /var/www/html && \
  chown -R nobody.nobody /run && \
  chown -R nobody.nobody /var/lib/nginx && \
  chown -R nobody.nobody /var/log/nginx && \
  chown -R nobody.nobody /var/log/php8 && \
  chown -R nobody.nobody /etc/supervisor/conf.d/supervisord.conf

# Switch to use a non-root user from here on
USER nobody

# Expose the port nginx is reachable on
EXPOSE 80 443

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]