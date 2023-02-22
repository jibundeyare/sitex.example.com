#!/bin/bash

source websitesconf.sh

sudo systemctl stop apache2
sudo systemctl stop php$php_version-fpm

ids="$(seq -w $websites_start $websites_end)"

for id in $ids
do
	username="$website_prefix$id"

	echo "deleting $username"

	# account
	sudo userdel $username

	# folder
	sudo rm -fr /home/$username

	# vhost
	sudo a2dissite $username
	sudo rm /etc/apache2/sites-available/$username.conf
	sudo rm /var/log/apache2/$username.$domain.access.log*
	sudo rm /var/log/apache2/$username.$domain.error.log*

	# database
	echo "DROP USER '$username'@'localhost';" | sudo mysql
	echo "DROP DATABASE $username;" | sudo mysql
	echo "FLUSH PRIVILEGES;" | sudo mysql

	# php fpm
	sudo rm /etc/php/$php_version/fpm/pool.d/$username.conf

	# remove the dedicated php session directory
	sudo rm -r /var/lib/php/sessions/$username

done

sudo systemctl start apache2
sudo systemctl start php$php_version-fpm

