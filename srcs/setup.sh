#!/bin/bash

/etc/init.d/php7.3-fpm start

service mysql start
echo "CREATE DATABASE wordpress;" | mysql -u root --skip-password
echo "GRANT ALL PRIVILEGES ON wordpress.* TO 'root'@'localhost';" | mysql -u root --skip-password
echo "FLUSH PRIVILEGES;" | mysql -u root --skip-password
echo "update mysql.user set plugin = 'mysql_native_password' where user='root';" | mysql -u root

if [[ $AUTOINDEX == "off" ]]
then 
	sed -i 's/autoindex on/autoindex off/' /etc/nginx/sites-available/testsite
fi

service nginx start
