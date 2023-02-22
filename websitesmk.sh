#!/bin/bash

source websitesconf.sh

ids="$(seq -w $websites_start $websites_end)"

for id in $ids
do
	username="$website_prefix$id"

	echo "creating $username"

	# account
	sudo useradd $username
	sudo usermod -s /bin/bash $username

	# folder
	sudo cp -r /etc/skel /home/$username
	sudo mkdir -p /home/$username/www

	# copy php index file to website directory
	sudo cp template-index.php /home/$username/www/index.php

	# edit file to match selected username
	sudo sed -i "s/{username}/$username/g" /home/$username/www/index.php

	# set owner and permissions of website directory
	sudo chown -R $username:$username /home/$username
	sudo chmod 755 /home/$username/www
	sudo find /home/$username/www -type d -exec chmod 755 {}\;
	sudo find /home/$username/www -type f -exec chmod 644 {}\;

	# copy vhost file to apache2 directory
	sudo cp $vhost_template /etc/apache2/sites-available/$username.conf

	# edit file to match selected username
	sudo sed -i "s/{domain}/$domain/g" /etc/apache2/sites-available/$username.conf
	sudo sed -i "s/{username}/$username/g" /etc/apache2/sites-available/$username.conf
	sudo a2ensite $username

	# create database and database user
	echo "CREATE DATABASE $username DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" | sudo mysql
	echo "CREATE USER '$username'@'localhost';" | sudo mysql
	echo "GRANT ALL PRIVILEGES ON $username.* TO '$username'@'localhost';" | sudo mysql
	echo "FLUSH PRIVILEGES;" | sudo mysql

	# create a dedicated php session directory
	sudo mkdir -p /var/lib/php/sessions/$username

	# set appropriate rights (drwx-wx-wt) on the dedicated php sessions directory
	sudo chmod 1733 /var/lib/php/sessions/$username

	# copy pool template file to php fpm pool directory
	sudo cp template-pool.conf /etc/php/$php_version/fpm/pool.d/$username.conf

	# edit file to match selected username
	sudo sed -i "s/{username}/$username/g" /etc/php/$php_version/fpm/pool.d/$username.conf
	sudo sed -i "s/{domain}/$domain/g" /etc/php/$php_version/fpm/pool.d/$username.conf
done

sudo systemctl restart apache2
sudo systemctl restart php$php_version-fpm

