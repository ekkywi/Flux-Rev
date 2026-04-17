# =================
# STAGE 1 : BASE
# =================
FROM php:8.4-fpm-bookworm AS base

RUN apt-get update && apt-get install -y \
    libpq-dev \
    libzip-dev \
    unzip \
    curl \
    procps \
    nano \
    && docker-php-ext-install pdo pdo_pgsql zip pcntl

RUN pecl install redis && docker-php-ext-enable redis

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# =====================
# STAGE 2 : DEVELOPMENT
# =====================
FROM base AS development

RUN apt-get update && apt-get install -y --no-install-recommends \
    zsh git curl ca-certificates unzip \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

RUN usermod -s /usr/bin/zsh root \
    && usermod -s /usr/bin/zsh www-data

RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

WORKDIR /var/www/html

CMD ["php-fpm"]

# ===================
# BASE 3 : PRODUCTION
# ===================
FROM base AS prod

COPY . .

RUN composer install --no-dev --optimize-autoloader

RUN npm install && npm run build

RUN apt-get remove -y nodejs \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache

USER www-data

CMD ["php-fpm"]