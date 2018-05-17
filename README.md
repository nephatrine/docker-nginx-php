[GitHub](https://github.com/nephatrine/docker-base-php7) |
[DockerHub](https://hub.docker.com/r/nephatrine/base-php7/) |
[unRAID](https://github.com/nephatrine/unraid-docker-templates)

# PHP7 Base Docker

This is not intended to be used directly. It is intended to be used as a base image by other dockers. It could potentially be used for PHP application development or testing though.

It runs [PHP7](http://www.php.net/) on top of my [Alpine+NGINX](https://github.com/nephatrine/docker-nginx-ssl) docker. Compiling PHP is not quick and so I split this out into its own docker so I can iterate on the ones that depend on it without waiting around forever for it to build them.

Certbot (LetsEncrypt) is installed to handle obtaining SSL certs in case this is your only web docker. If you plan on hosting multiple applications/dockers, though I suggest having one [nginx-ssl](https://hub.docker.com/r/nephatrine/nginx-ssl/) docker that is publicly visible and handles the SSL certs for all domains. That docker can then proxy all your other nginx dockers which would actually be running on non-public IPs under plain HTTP.

## Settings

- **ADMINIP:** Administrative Access IP
- **DNSADDR:** Resolver IPs (Space-Delimited)
- **PUID:** Volume Owner UID
- **PGID:** Volume Owner GID
- **SSLEMAIL:** LetsEncrypt Email Address
- **SSLDOMAINS:** LetsEncrypt (Sub)domains (comma-delimited)
- **TZ:** Time Zone

## Mount Points

- **/mnt/config:** Configuration Volume