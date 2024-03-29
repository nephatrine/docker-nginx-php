# SPDX-FileCopyrightText: 2018 - 2024 Daniel Wolf <nephatrine@gmail.com>
#
# SPDX-License-Identifier: ISC

location ~ \.php$ {
	try_files $uri =404;
	fastcgi_pass unix:/var/run/php-fpm/php-fpm.sock;
	include /etc/nginx/fastcgi_params;
	fastcgi_param SCRIPT_FILENAME $document_root/$fastcgi_script_name;
}