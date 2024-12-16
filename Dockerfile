FROM trafex/php-nginx:latest

LABEL maintainer="G.U.D. Chalmers <gud@chs.se>"
LABEL description="Customized version of trafex/php-nginx for BlueMap."

# Set BlueMap version
ARG BLUEMAP_VERSION=5.5

# Set user to root for installation
USER root

# Install dependencies
RUN apk add --no-cache curl unzip

# Download and extract BlueMap.jar to temporary directory
RUN tmpdir=$(mktemp -d) && \
    curl -L "https://github.com/BlueMap-Minecraft/BlueMap/releases/download/v${BLUEMAP_VERSION}/BlueMap-${BLUEMAP_VERSION}-spigot.jar" -o "${tmpdir}/BlueMap.jar" && \
    unzip "${tmpdir}/BlueMap.jar" -d "${tmpdir}" && \
    unzip "${tmpdir}/de/bluecolored/bluemap/webapp.zip" -d /var/www/html && \
    chown -R nobody:nobody /var/www/html && \
    rm -rf "${tmpdir}"

# Patch sql.php to use database credentials from environment variables
RUN sed -i "s/\$driver   = .*/$driver   = getenv('DB_DRIVER') ?: 'mysql';/" /var/www/html/sql.php && \
    sed -i "s/\$hostname = .*/$hostname = getenv('DB_HOST') ?: '127.0.0.1';/" /var/www/html/sql.php && \
    sed -i "s/\$port     = .*/$port     = getenv('DB_PORT') ?: 3306;/" /var/www/html/sql.php && \
    sed -i "s/\$username = .*/$username = getenv('DB_USER') ?: 'root';/" /var/www/html/sql.php && \
    sed -i "s/\$password = .*/$password = getenv('DB_PASSWORD') ?: '';/" /var/www/html/sql.php && \
    sed -i "s/\$database = .*/$database = getenv('DB_NAME') ?: 'bluemap';/" /var/www/html/sql.php && \
    sed -i "s/\$hiresCompression = .*/$hiresCompression = getenv('HIRES_COMPRESSION') ?: 'gzip';/" /var/www/html/sql.php

# Copy nginx configuration
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/conf.d /etc/nginx/conf.d/

# Set user back to nobody
USER nobody
