#!/bin/bash

source websitesconf.sh

html_template="./template-index.html"
php_template="./template-test.php"
vhost_template="./template-vhost.conf"
pool_template="./template-pool.conf"

ids="$(seq -w $websites_count)"

for id in $ids
do
	my_user="site${id}"

	echo "creating $my_user"

	# account
	useradd $my_user
	usermod -s /bin/bash $my_user

	# folder
	cp -r /etc/skel /home/$my_user
	mkdir /home/$my_user/www
	cp $html_template /home/$my_user/www/index.html
	sed -i "s/{my_user}/$my_user/g" /home/$my_user/www/index.html
	cp $php_template /home/$my_user/www/test.php
	chown -R $my_user:$my_user /home/$my_user

	# vhost
	cp $vhost_template /etc/apache2/sites-available/$my_user.conf
	sed -i "s/{my_user}/$my_user/g" /etc/apache2/sites-available/$my_user.conf
	a2ensite $my_user

	# database
	echo "CREATE DATABASE $my_user DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" | mysql
	echo "CREATE USER '$my_user'@'%';" | mysql
	echo "GRANT ALL PRIVILEGES ON $my_user.* TO '$my_user'@'%';" | mysql
	echo "FLUSH PRIVILEGES;" | mysql

	# php fpm
	cp $pool_template /etc/php/7.3/fpm/pool.d/$my_user.conf
	sed -i "s/{my_user}/$my_user/g" /etc/php/7.3/fpm/pool.d/$my_user.conf
done

systemctl restart apache2
systemctl restart php7.3-fpm

