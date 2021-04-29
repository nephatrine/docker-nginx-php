FROM nephatrine/nginx-ssl:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL PACKAGES ======" \
 && apk add \
   argon2-libs aspell \
   c-client \
   gmp \
   icu-libs \
   libcurl libintl libsodium libzip \
   mariadb-client \
   oniguruma \
   sqlite \
   tidyhtml-libs \
   yaml \
 && rm -rf /var/cache/apk/*

ARG PHP_VERSION=PHP-8.0

RUN echo "====== COMPILE PHP ======" \
 && apk add --virtual .build-php \
   argon2-dev aspell-dev autoconf \
   bison build-base bzip2-dev \
   curl-dev \
   expat-dev \
   freetype-dev \
   gettext-dev git gmp-dev \
   icu-dev imap-dev \
   libjpeg-turbo-dev libpng-dev libressl-dev libsodium-dev libwebp-dev libxml2-dev libxslt-dev libzip-dev linux-headers \
   mariadb-dev \
   oniguruma-dev \
   re2c readline-dev \
   sqlite-dev \
   tidyhtml-dev \
   yaml-dev \
   zlib-dev \
 && git -C /usr/src clone -b "$PHP_VERSION" --single-branch --depth=1 https://github.com/php/php-src.git && cd /usr/src/php-src \
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
 && make -j4 \
 && make install \
 && cp php.ini-production /etc/php/php.ini \
 && pear update-channels \
 && pear upgrade --force \
 && yes '' | pecl install yaml \
 && strip /usr/bin/php \
 && strip /usr/sbin/php-fpm \
 && strip /usr/lib/php/*/*.so \
 && cd /usr/src && rm -rf /usr/src/* \
 && rm -rf /usr/include/php /usr/lib/php/*/*.a /usr/lib/php/build \
 && apk del --purge .build-php && rm -rf /var/cache/apk/*

RUN echo "====== CONFIGURE SYSTEM ======" \
 && mkdir -p /etc/php/php.d /var/lib/php /var/run/php-fpm \
 && echo "[PHP]" >>/etc/php/php.d/extensions.ini \
 && ls /usr/lib/php/*/*.so | egrep 'curl|gd|mbstring|sqlite|yaml|zip' | tr '/' ' ' | tr '.' ' ' | awk '{print $(NF-1)}' | xargs -n1 -I{} echo "extension={}" >>/etc/php/php.d/extensions.ini \
 && ls /usr/lib/php/*/*.so | egrep -v 'curl|gd|mbstring|opcache|sqlite|yaml|zip' | tr '/' ' ' | tr '.' ' ' | awk '{print $(NF-1)}' | xargs -n1 -I{} echo ";extension={}" >>/etc/php/php.d/extensions.ini \
 && ls /usr/lib/php/*/*.so | egrep 'opcache' | tr '/' ' ' | tr '.' ' ' | awk '{print $(NF-1)}' | xargs -n1 -I{} echo "zend_extension={}" >>/etc/php/php.d/extensions.ini \
 && sed -i 's/index.html/index.php index.html/g' /etc/nginx/nginx.conf

COPY override /