# docker-bluemap-nginx
Customized version of trafex/php-nginx with BlueMap webapp pre-installed.

[![Build and push Docker image](https://github.com/Arcadia-MC/docker-bluemap/actions/workflows/docker-build.yml/badge.svg)](https://github.com/Arcadia-MC/docker-bluemap/actions/workflows/docker-build.yml)

## How to use?
You can deploy this image using Docker Compose. Here is an example of a [docker-compose.yml](https://github.com/Arcadia-MC/docker-bluemap/blob/master/docker-compose.yml) file:
```yaml
services:
  bluemap:
    image: ghcr.io/Arcadia-MC/docker-bluemap:latest
    environment:
      - DB_DRIVER=mariadb
      - DB_HOST=${DB_HOST}
      - DB_PORT=${DB_PORT:-3306}
      - DB_USER=${DB_USER}
      - DB_PASSWORD=${DB_PASSWORD}
      - DB_NAME=${DB_DATABASE}
    configs:
      - source: settings.json
        target: /var/www/html/settings.json
    networks:
      - traefik
    restart: unless-stopped
    labels:
      - "traefik.enable=true"
      - "traefik.http.services.bluemap.loadBalancer.server.port=80"
      - "traefik.http.routers.bluemap-local.entrypoints=http,https"
      - "traefik.http.routers.bluemap-local.rule=Host(`domain.local`)"

configs:
  settings.json:
    content: |
      {
        "version": "5.11",
        "useCookies": true,
        "defaultToFlatView": false,
        "resolutionDefault": 1.0,
        "minZoomDistance": 5,
        "maxZoomDistance": 100000,
        "hiresSliderMax": 500,
        "hiresSliderDefault": 100,
        "hiresSliderMin": 0,
        "lowresSliderMax": 7000,
        "lowresSliderDefault": 2000,
        "lowresSliderMin": 500,
        "mapDataRoot": "maps",
        "liveDataRoot": "maps",
        "maps": [
            "smp_world",
            "smp_world_nether",
            "smp_world_the_end",
            "creative_plotworld"
        ],
        "scripts": [],
        "styles": []
      }

networks:
  traefik:
    name: traefik
    external: true
```

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
