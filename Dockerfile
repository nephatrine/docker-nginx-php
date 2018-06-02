FROM nephatrine/nginx-ssl:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== RUNTIME CONFIGURATION ======" \
 && apk --update upgrade \
 && apk add \
  argon2-libs \
  c-client \
  git \
  gmp \
  icu-libs \
  libcurl \
  libintl \
  libldap \
  libsasl \
  libsodium \
  libxpm \
  libzip \
  mariadb-client \
  net-snmp-libs \
  oniguruma \
  tidyhtml-libs \
  yaml \
 && mkdir -p /etc/php/php.d /var/lib/php /var/run/php-fpm \
 \
 && echo "====== BUILD CONFIGURATION ======" \
 && apk add --virtual .build-php \
  argon2-dev \
  autoconf \
  bison \
  bzip2-dev \
  curl-dev \
  cyrus-sasl-dev \
  expat-dev \
  freetype-dev \
  g++ \
  gd-dev \
  gettext-dev \
  gmp-dev \
  icu-dev \
  imap-dev \
  krb5-dev \
  libc-dev \
  libjpeg-turbo-dev \
  libpng-dev \
  libressl-dev \
  libsodium-dev \
  libwebp-dev \
  libxml2-dev \
  libxpm-dev \
  libxslt-dev \
  libzip-dev \
  linux-headers \
  make \
  mariadb-dev \
  net-snmp-dev \
  oniguruma-dev \
  openldap-dev \
  pcre-dev \
  readline-dev \
  sqlite-dev \
  tidyhtml-dev \
  yaml-dev \
  zlib-dev \
 \
 && echo "====== COMPILE PHP ======" \
 && cd /usr/src \
 && git clone https://github.com/php/php-src.git && cd php-src \
 && git fetch origin PHP-7.2 && git checkout PHP-7.2 \
 && ./buildconf --force && ./configure \
  --prefix=/usr \
  --sysconfdir=/etc/php \
  --localstatedir=/var \
  --libdir=/usr/lib/php \
  --datadir=/usr/share/php \
  --build=$CBUILD \
  --host=$CHOST \
  --enable-re2c-cgoto \
  --enable-fpm \
  --with-fpm-user=guardian \
  --with-fpm-group=users \
  --disable-cgi \
  --disable-phpdbg \
  --disable-phpdbg-webhelper \
  --with-layout=GNU \
  --with-config-file-path=/etc/php \
  --with-config-file-scan-dir=/mnt/config/etc/php.d \
  --disable-short-tags \
  --with-libxml-dir=/usr \
  --with-openssl=/usr \
  --with-kerberos=/usr \
  --with-system-ciphers \
  --with-pcre-regex=/usr \
  --with-sqlite3=shared,/usr \
  --with-zlib=/usr \
  --with-zlib-dir=/usr \
  --enable-bcmath=shared \
  --with-bz2=shared,/usr \
  --enable-calendar=shared \
  --with-curl=shared,/usr \
  --enable-exif=shared \
  --with-pcre-dir=/usr \
  --enable-ftp=shared \
  --with-openssl-dir=/usr \
  --with-gd=shared,/usr \
  --with-webp-dir=/usr \
  --with-jpeg-dir=/usr \
  --with-png-dir=/usr \
  --with-xpm-dir=/usr \
  --with-freetype-dir=/usr \
  --with-gettext=shared,/usr \
  --with-gmp=shared,/usr \
  --with-iconv=shared \
  --with-imap=shared,/usr \
  --with-imap-ssl=/usr \
  --enable-intl=shared \
  --with-icu-dir=/usr \
  --with-ldap=shared,/usr \
  --with-ldap-sasl=/usr \
  --enable-mbstring=shared \
  --with-libmbfl \
  --with-onig=/usr \
  --with-mysqli=shared,mysqlnd \
  --enable-pcntl=shared \
  --with-pdo-mysql=shared,mysqlnd \
  --with-pdo-sqlite=shared,/usr \
  --with-readline=/usr \
  --enable-shmop=shared \
  --with-snmp=shared,/usr \
  --enable-soap=shared \
  --enable-sockets=shared \
  --with-sodium=shared,/usr \
  --with-password-argon2=/usr \
  --enable-sysvmsg=shared \
  --enable-sysvsem=shared \
  --enable-sysvshm=shared \
  --with-tidy=shared,/usr \
  --enable-wddx=shared \
  --with-libexpat-dir=/usr \
  --with-xsl=shared,/usr \
  --enable-zip=shared \
  --with-libzip=/usr \
  --enable-mysqlnd=shared \
  --with-pear=/usr/share/php \
  --with-pic \
 && wget -Oopenssl.c.patch 'https://bugs.php.net/patch-display.php?bug_id=76174&patch=patch-ext-openssl_openssl.c&revision=1522614841&download=1' \
 && patch /usr/src/php-src/ext/openssl/openssl.c openssl.c.patch \
 && make -j4 && make install \
 && strip /usr/bin/php \
 && strip /usr/sbin/php-fpm \
 && strip /usr/lib/php/*/*.so \
 \
 && echo "====== INSTALL YAML ======" \
 && pear update-channels \
 && pear upgrade --force \
 && yes '' | pecl install yaml \
 && strip /usr/lib/php/*/yaml.so \
 \
 && echo "====== CONFIGURE PHP ======" \
 && cp php.ini-production /etc/php/php.ini \
 && echo "[PHP]" >>/etc/php/php.d/extensions.ini \
 && ls /usr/lib/php/*/*.so | egrep 'curl|gd|mbstring|sqlite|yaml|zip' | tr '/' ' ' | tr '.' ' ' | awk '{print $(NF-1)}' | xargs -n1 -I{} echo "extension={}" >>/etc/php/php.d/extensions.ini \
 && ls /usr/lib/php/*/*.so | egrep -v 'curl|gd|mbstring|opcache|sqlite|yaml|zip' | tr '/' ' ' | tr '.' ' ' | awk '{print $(NF-1)}' | xargs -n1 -I{} echo ";extension={}" >>/etc/php/php.d/extensions.ini \
 && ls /usr/lib/php/*/*.so | egrep 'opcache' | tr '/' ' ' | tr '.' ' ' | awk '{print $(NF-1)}' | xargs -n1 -I{} echo "zend_extension={}" >>/etc/php/php.d/extensions.ini \
 && sed -i 's/index.html/index.php index.html/g' /etc/nginx/nginx.conf \
 \
 && echo "====== CLEANUP ======" \
 && cd /usr/src \
 && apk del --purge .build-php \
 && rm -rf \
  /tmp/* \
  /usr/include/php \
  /usr/lib/php/*/*.a \
  /usr/lib/php/build \
  /usr/src/* \
  /var/cache/apk/*

COPY override /