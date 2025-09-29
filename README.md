# docker-bluemap-nginx
Customized version of trafex/php-nginx with BlueMap webapp pre-installed.

[![Build and push Docker image](https://github.com/Neplex/docker-bluemap/actions/workflows/docker-build.yml/badge.svg)](https://github.com/Neplex/docker-bluemap/actions/workflows/docker-build.yml)

## How to use?
You can deploy this image using Docker Compose. Here is an example of a [docker-compose.yml](https://github.com/Neplex/docker-bluemap/blob/master/docker-compose.yml) file:
```yaml
version: "3.8"
services:
  bluemap:
    image: ghcr.io/gudchalmers/bluemap-nginx:latest
    restart: unless-stopped
    ports:
      - "8100:80/tcp"
    depends_on:
      - mariadb
    environment:
      DB_DRIVER: mariadb
      DB_HOST: mariadb
      DB_PORT: '3306'
      DB_USER: bluemap
      DB_PASSWORD: thisisaverysecurepassword
      DB_NAME: bluemap
    volumes:
      - ./data/settings.json:/var/www/html/settings.json

  mariadb:
    image: mariadb:10.5
    restart: unless-stopped
    environment:
      MYSQL_USER: bluemap
      MYSQL_PASSWORD: thisisaverysecurepassword
      MYSQL_INITDB_SKIP_TZINFO: '1'
    volumes:
      - mysql-vol:/var/lib/mysql

volumes:
  mysql-vol:
```

You can also deploy this image using the following command:
```bash
docker run -d \
  --name bluemap \
  -p 8100:80/tcp \
  -e DB_DRIVER=mariadb \
  -e DB_HOST=mariadb \
  -e DB_PORT=3306 \
  -e DB_USER=bluemap \
  -e DB_PASSWORD=thisisaverysecurepassword \
  -e DB_NAME=bluemap \
  -v ./data/settings.json:/var/www/html/settings.json \
  ghcr.io/gudchalmers/bluemap-nginx:latest
```

Note that in both cases, you need to create a `settings.json` file in the `./data` directory. You can also find this file in the BlueMap webroot directory.

## Environment variables
| Variable      | Description                     | Default value |
|---------------|---------------------------------|---------------|
| `DB_DRIVER`   | Type of database                | `mysql`       |
| `DB_HOST`     | Hostname of the database server | `127.0.0.1`   |
| `DB_PORT`     | Port of the database server     | `3306`        |
| `DB_USER`     | Username of the database user   | `root`        |
| `DB_PASSWORD` | Password of the database user   | `""`          |
| `DB_NAME`     | Name of the database database   | `bluemap`     |

## Limitations
- This image does not support HTTPS out of the box. You need to modify the Nginx `default.conf` in order to enable HTTPS or use a reverse proxy.
- You need to enable `write-markers-interval` and `write-players-interval` in BlueMap in order for live data to be written to the database.  This will incur a lot of writes to your database, however.

You can also modify the `default.conf` to [proxy live data requests](https://bluemap.bluecolored.de/wiki/webserver/ExternalWebserversSQL.html) to the BlueMap integrated webserver.  This is the recommended method for external services to access live player locations.
