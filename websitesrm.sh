#!/bin/bash

source websitesconf.sh

systemctl stop apache2
systemctl stop php$php_version-fpm

ids="$(seq -w $websites_start $websites_end)"

for id in $ids
do
	username="$website_prefix$id"

	echo "deleting $username"

	# account
	userdel $username

	# folder
	rm -fr /home/$username

	# vhost
	a2dissite $username
	rm /etc/apache2/sites-available/$username.conf
	rm /var/log/apache2/$username.$domain.access.log*
	rm /var/log/apache2/$username.$domain.error.log*

	# database
	echo "DROP USER '$username'@'localhost';" | mysql
	echo "DROP DATABASE $username;" | mysql
	echo "FLUSH PRIVILEGES;" | mysql

	# php fpm
	rm /etc/php/$php_version/fpm/pool.d/$username.conf

	# remove the dedicated php session directory
	rm -r /var/lib/php/sessions/$username

done

systemctl start apache2
systemctl start php$php_version-fpm

