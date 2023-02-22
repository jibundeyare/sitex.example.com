#!/bin/bash

source websitesconf.sh

ids="$(seq -w $websites_start $websites_end)"

for id in $ids
do
	username="$website_prefix$id"

	echo "creating $username"

	# account
	useradd $username
	usermod -s /bin/bash $username

	# folder
	cp -r /etc/skel /home/$username
	mkdir /home/$username/www

	# copy php index file to website directory
	cp template-index.php /home/$username/www/index.php

	# edit file to match selected username
	sed -i "s/{username}/$username/g" /home/$username/www/index.php

	# set owner and permissions of website directory
	chown -R $username:$username /home/$username
	chmod 755 /home/$username/www
	find /home/$username/www -t d -exec chmod 755 {}\;
	find /home/$username/www -t f -exec chmod 644 {}\;

	# copy vhost file to apache2 directory
	cp $vhost_template /etc/apache2/sites-available/$username.conf

	# edit file to match selected username
	sed -i "s/{domain}/$domain/g" /etc/apache2/sites-available/$username.conf
	sed -i "s/{username}/$username/g" /etc/apache2/sites-available/$username.conf
	a2ensite $username

	# create database and database user
	echo "CREATE DATABASE $username DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" | mysql
	echo "CREATE USER '$username'@'localhost';" | mysql
	echo "GRANT ALL PRIVILEGES ON $username.* TO '$username'@'localhost';" | mysql
	echo "FLUSH PRIVILEGES;" | mysql

	# create a dedicated php session directory
	mkdir /var/lib/php/sessions/$username

	# set appropriate rights (drwx-wx-wt) on the dedicated php sessions directory
	chmod 1733 /var/lib/php/sessions/$username

	# copy pool template file to php fpm pool directory
	cp template-pool.conf /etc/php/$php_version/fpm/pool.d/$username.conf

	# edit file to match selected username
	sed -i "s/{username}/$username/g" /etc/php/$php_version/fpm/pool.d/$username.conf
	sed -i "s/{domain}/$domain/g" /etc/php/$php_version/fpm/pool.d/$username.conf
done

systemctl restart apache2
systemctl restart php$php_version-fpm

