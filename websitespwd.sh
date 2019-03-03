#!/bin/bash

source websitesconf.sh

ids="$(seq -w $websites_count)"

for id in $ids
do
	my_user="site${id}"

	echo "updating password for $my_user"

	# account
	echo "$my_user:$base_passwd$my_user" | chpasswd

	# database
	echo "GRANT USAGE ON *.* TO '$my_user'@'%' IDENTIFIED BY '$mysql_passwd_base$my_user';" | mysql
done

systemctl restart sshd

