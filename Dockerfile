FROM nephatrine/nxbuilder:alpine AS builder

RUN echo "====== INSTALL LIBRARIES ======" \
 && apk add --no-cache \
  argon2-dev aspell-dev bzip2-dev expat-dev freetype-dev gettext-dev gmp-dev \
  imap-dev libjpeg-turbo-dev libpng-dev libsodium-dev libwebp-dev libxslt-dev \
  libzip-dev mariadb-dev oniguruma-dev re2c readline-dev sqlite-dev \
  tidyhtml-dev yaml-dev

ARG PHP_VERSION=PHP-8.2.7
RUN git -C /root clone -b "$PHP_VERSION" --single-branch --depth=1 https://github.com/php/php-src.git

RUN echo "====== COMPILE PHP ======" \
 && cd /root/php-src \
 && ./buildconf --force \
 && ./configure \
  --prefix=/usr \
  --sysconfdir=/etc/php \
  --localstatedir=/var \
  --libdir=/usr/lib/php \
  --datadir=/usr/share/php \
  --enable-re2c-cgoto \
  --enable-fpm \
  --with-fpm-user=guardian \
  --with-fpm-group=users \
  --disable-cgi \
  --disable-phpdbg \
  --disable-phpdbg-webhelper \
  --disable-short-tags \
  --with-layout=GNU \
  --with-config-file-path=/etc/php \
  --with-config-file-scan-dir=/mnt/config/etc/php.d \
  --with-pear=/usr/share/php \
  --with-pic \
  --enable-bcmath=shared \
  --enable-calendar=shared \
  --enable-exif=shared \
  --enable-ftp=shared \
  --enable-gd=shared --with-freetype=/usr --with-jpeg=/usr --with-webp=/usr \
  --enable-intl=shared \
  --enable-mbstring=shared \
  --enable-mysqlnd=shared \
  --enable-opcache=shared \
  --enable-pcntl=shared \
  --enable-shmop=shared \
  --enable-soap=shared \
  --enable-sockets=shared \
  --enable-sysvmsg=shared \
  --enable-sysvsem=shared \
  --enable-sysvshm=shared \
  --with-bz2=shared,/usr \
  --with-curl=shared,/usr \
  --with-gettext=shared,/usr \
  --with-gmp=shared,/usr \
  --with-iconv=shared \
  --with-imap=shared,/usr --with-imap-ssl=/usr \
  --with-mysqli=shared,mysqlnd \
  --with-openssl=/usr \
  --with-password-argon2=/usr \
  --with-pdo-mysql=shared,mysqlnd \
  --with-pdo-sqlite=shared,/usr \
  --with-pspell=shared,/usr \
  --with-readline=/usr \
  --with-sodium=shared,/usr \
  --with-sqlite3=shared,/usr \
  --with-tidy=shared,/usr \
  --with-xsl=shared,/usr \
  --with-zip=shared,/usr \
  --with-zlib=/usr \
 && make -j$(( $(getconf _NPROCESSORS_ONLN) / 2 + 1 )) \
 && make -j$(( $(getconf _NPROCESSORS_ONLN) / 2 + 1 )) install \
 && cp php.ini-production /etc/php/php.ini

RUN echo "====== UPDATE PEAR ======" \
 && pear update-channels && pear upgrade --force \
 && yes '' | pecl install yaml

FROM nephatrine/nginx-ssl:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL PACKAGES ======" \
 && apk add --no-cache \
  argon2-libs aspell c-client freetype gmp icu-libs libcurl libintl \
  libjpeg-turbo libpng libsodium libwebp libxml2 libzip mariadb-client \
  oniguruma sqlite-libs tidyhtml-libs yaml \
 && sed -i 's/index.html/index.php index.html/g' /etc/nginx/nginx.conf \
 && mkdir -p /etc/php/php.d /usr/lib/php /usr/share/php /var/lib/php /var/run/php-fpm

COPY --from=builder /etc/php/ /etc/php/
COPY --from=builder \
 /usr/bin/pear /usr/bin/peardev /usr/bin/pecl \
 /usr/bin/php /usr/bin/php-config /usr/bin/phpize \
 /usr/bin/
COPY --from=builder /usr/lib/php/ /usr/lib/php/
COPY --from=builder /usr/share/php/ /usr/share/php/
COPY --from=builder /usr/sbin/php-fpm /usr/sbin/
COPY override /

RUN echo "====== Handle Extensions ======" \
 && echo "[PHP]" >>/etc/php/php.d/extensions.ini \
 && ls /usr/lib/php/*/*.so | egrep 'curl|gd|mbstring|sqlite|yaml|zip' | tr '/' ' ' | tr '.' ' ' | awk '{print $(NF-1)}' | xargs -n1 -I{} echo "extension={}" >>/etc/php/php.d/extensions.ini \
 && ls /usr/lib/php/*/*.so | egrep -v 'curl|gd|mbstring|opcache|sqlite|yaml|zip' | tr '/' ' ' | tr '.' ' ' | awk '{print $(NF-1)}' | xargs -n1 -I{} echo ";extension={}" >>/etc/php/php.d/extensions.ini \
 && ls /usr/lib/php/*/*.so | egrep 'opcache' | tr '/' ' ' | tr '.' ' ' | awk '{print $(NF-1)}' | xargs -n1 -I{} echo "zend_extension={}" >>/etc/php/php.d/extensions.ini
