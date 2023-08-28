[Git](https://code.nephatrine.net/NephNET/docker-nginx-php/src/branch/master) |
[Docker](https://hub.docker.com/r/nephatrine/nginx-php/) |
[unRAID](https://code.nephatrine.net/NephNET/unraid-containers)

# NGINX PHP Web Server

This docker container manages the NGINX application with PHP support for web
development or application hosting.

The `latest` tag points to version `8.2.9` and this is the only image actively
being updated. There are tags for older versions, but these may no longer be
using the latest NGINX version or Alpine version and packages.

If using this as a standalone web server, you can configure TLS the same way as
the [nginx-ssl](https://code.nephatrine.net/NephNET/docker-nginx-ssl) container.
If part of a larger envinronment, we suggest using a separate container as a
reverse proxy server and handle TLS there instead.

This container is primarily intended to be used as a base image for PHP web
applications.

## Docker-Compose

This is an example docker-compose file:

```yaml
services:
  php:
    image: nephatrine/nginx-php:latest
    container_name: php
    environment:
      TZ: America/New_York
      PUID: 1000
      PGID: 1000
      ADMINIP: 127.0.0.1
      TRUSTSN: 192.168.0.0/16
      DNSADDR: "8.8.8.8 8.8.4.4"
    ports:
      - "8080:80/tcp"
    volumes:
      - /mnt/containers/php:/mnt/config
```

## Server Configuration

These are the configuration and data files you will likely need to be aware of
and potentially customize.

- `/mnt/config/etc/mime.type`
- `/mnt/config/etc/nginx.conf`
- `/mnt/config/etc/nginx.d/*`
- `/mnt/config/www/default/*`
- `/mnt/config/etc/php.d/*`
- `/mnt/config/etc/php.ini`
- `/mnt/config/etc/php-fpm.conf`
- `/mnt/config/etc/php-fpm.d/*`

Modifications to some of these may require a service restart to pull in the
changes made.
