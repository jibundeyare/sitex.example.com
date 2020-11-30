#!/bin/bash

source websitesconf.sh

systemctl stop apache2
systemctl stop php7.3-fpm

ids="$(seq -w $websites_seq_start $websites_seq_end)"

for id in $ids
do
	my_user="site${id}"

	echo "deleting $my_user"

	# account
	userdel $my_user

	# folder
	rm -fr /home/$my_user

	# vhost
	a2dissite $my_user
	rm /etc/apache2/sites-available/$my_user.conf
	rm /var/log/apache2/$my_user.$domain_name.access.log*
	rm /var/log/apache2/$my_user.$domain_name.error.log*

	# database
	echo "DROP USER '$my_user'@'%';" | mysql
	echo "DROP DATABASE $my_user;" | mysql
	echo "FLUSH PRIVILEGES;" | mysql

	# php fpm
	rm /etc/php/7.3/fpm/pool.d/$my_user.conf
done

systemctl start apache2
systemctl start php7.3-fpm

