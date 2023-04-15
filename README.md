[Git](https://code.nephatrine.net/nephatrine/docker-nginx-php/src/branch/master) |
[Docker](https://hub.docker.com/r/nephatrine/nginx-php/) |
[unRAID](https://code.nephatrine.net/nephatrine/unraid-containers)

[![Build Status](https://ci.nephatrine.net/api/badges/nephatrine/docker-nginx-php/status.svg?ref=refs/heads/master)](https://ci.nephatrine.net/nephatrine/docker-nginx-php)

# PHP Web Server

This docker container manages the NGINX application with PHP support for web
development or application hosting.

If using this as a standalone web server, you can configure TLS the same way as
the [nginx-ssl](https://code.nephatrine.net/nephatrine/docker-nginx-ssl) container.
If part of a larger envinronment, we suggest using a separate container as a
reverse proxy server and handle TLS there rather than here.

- [Alpine Linux](https://alpinelinux.org/)
- [Skarnet Software](https://skarnet.org/software/)
- [S6 Overlay](https://github.com/just-containers/s6-overlay)
- [CertBot](https://certbot.eff.org/)
- [NGINX](https://www.nginx.com/)
- [PHP](https://www.php.net/)

You can spin up a quick temporary test container like this:

~~~
docker run --rm -p 80:80 -it nephatrine/nginx-php:latest /bin/bash
~~~

This container is primarily intended to be used as a base container for PHP web
applications.

## Docker Tags

- **nephatrine/nginx-php:latest**: PHP 8.2 / NGINX Mainline / Alpine Latest

## Configuration Variables

You can set these parameters using the syntax ``-e "VARNAME=VALUE"`` on your
``docker run`` command. Some of these may only be used during initial
configuration and further changes may need to be made in the generated
configuration files.

- ``ADMINIP``: Administrator IP (*127.0.0.1*) (INITIAL CONFIG)
- ``DNSADDR``: Resolver IPs (*8.8.8.8 8.8.4.4*) (INITIAL CONFIG)
- ``PUID``: Mount Owner UID (*1000*)
- ``PGID``: Mount Owner GID (*100*)
- ``TRUSTSN``: Trusted Subnet (*192.168.0.0/16*) (INITIAL CONFIG)
- ``TZ``: System Timezone (*America/New_York*)

## Persistent Mounts

You can provide a persistent mountpoint using the ``-v /host/path:/container/path``
syntax. These mountpoints are intended to house important configuration files,
logs, and application state (e.g. databases) so they are not lost on image
update.

- ``/mnt/config``: Persistent Data.

Do not share ``/mnt/config`` volumes between multiple containers as they may
interfere with the operation of one another.

You can perform some basic configuration of the container using the files and
directories listed below.

- ``/mnt/config/etc/crontabs/<user>``: User Crontabs.
- ``/mnt/config/etc/logrotate.conf``: Logrotate Global Configuration.
- ``/mnt/config/etc/logrotate.d/``: Logrotate Additional Configuration.
- ``/mnt/config/etc/mime.type``: NGINX MIME Types.
- ``/mnt/config/etc/nginx.conf``: NGINX Configuration.
- ``/mnt/config/etc/nginx.d/``: NGINX Configuration.
- ``/mnt/config/etc/php.d/*``: PHP Extension Configuration
- ``/mnt/config/etc/php.ini``: PHP General Configuration
- ``/mnt/config/etc/php-fpm.conf``: PHP-FPM General Configuration
- ``/mnt/config/etc/php-fpm.d/*``: PHP-FPM Per-Site Configuration
- ``/mnt/config/www/default/``: Default HTML Location.

**[*] Changes to some configuration files may require service restart to take
immediate effect.**

## Network Services

This container runs network services that are intended to be exposed outside
the container. You can map these to host ports using the ``-p HOST:CONTAINER``
or ``-p HOST:CONTAINER/PROTOCOL`` syntax.

- ``80/tcp``: HTTP Server. This is the default insecure web server.
