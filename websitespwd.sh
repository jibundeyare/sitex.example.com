#!/bin/bash

source websitesconf.sh

ids="$(seq -w $websites_start $websites_end)"

for id in $ids
do
	username="$website_prefix$id"

	echo "updating password for $username"

	# set account password
	echo "$username:$user_passwd_base$username" | sudo chpasswd

	# set database user password
	echo "GRANT USAGE ON *.* TO '$username'@'localhost' IDENTIFIED BY '$mysql_passwd_base$username';" | sudo mysql
done

sudo systemctl restart sshd

