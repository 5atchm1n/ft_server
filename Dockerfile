# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: sshakya <sshakya@student.42.fr>            +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2021/02/21 10:41:36 by sshakya           #+#    #+#              #
#    Updated: 2021/02/21 18:11:03 by sshakya          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# Install the image from dockerhub (Debian Buster)
FROM debian:buster

ENV AUTOINDEX=on

# Update necessary packages to the latest version
RUN	apt-get update && apt-get install -y \
		nginx \
		mariadb-server \
		php-fpm \
		php-mysql \
		php-mbstring \
		wget \
		libnss3-tools \
		&& apt-get autoremove -y

## NGINX 
# copy testsite conf to nginx sites-available
RUN		echo "daemon off;" >> /etc/nginx/nginx.conf
COPY	srcs/nginx.conf /etc/nginx/sites-available/testsite
# link to sites-enable to allow access
RUN		ln -s /etc/nginx/sites-available/testsite /etc/nginx/sites-enabled/testsite

## PHPMYADMIN
# download latest version using wget
RUN		wget https://files.phpmyadmin.net/phpMyAdmin/5.0.4/phpMyAdmin-5.0.4-english.tar.gz && \
		tar -xzvf phpMyAdmin-5.0.4-english.tar.gz && \
		mv phpMyAdmin-5.0.4-english/ /var/www/html/phpmyadmin && \
		rm -rf phpMyAdmin-5.0.4-english.tar.gz
# copy conf file
COPY	srcs/phpmyadmin.conf /var/www/html/phpmyadmin/config.inc.php
## WORDPRESS
# download latest version of wordpress
RUN		wget https://wordpress.org/latest.tar.gz
RUN		tar -xzvf latest.tar.gz
RUN		mv wordpress /var/www/html
RUN		rm -rf latest.tar.gz
COPY	srcs/wordpress.conf /var/www/html/wordpress/wp-config.php
## SSL CERTIFICATE
# create a self signed certificate for production env. only
RUN		mkdir ~/mkcert && cd ~/mkcert && \
		wget https://github.com/FiloSottile/mkcert/releases/download/v1.4.3/mkcert-v1.4.3-linux-amd64 && \
		mv mkcert-v1.4.3-linux-amd64 mkcert && \
		chmod +x mkcert && \
		./mkcert -install && \
		./mkcert localhost

# GIVE NGINX USER ACCESS TO VAR/WWW/HTML
RUN		chown -R www-data:www-data /var/www/html/*
RUN		chmod 755 var/www/html

EXPOSE	80 443

COPY	srcs/setup.sh ./
CMD		bash setup.sh
