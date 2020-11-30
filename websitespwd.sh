#!/bin/bash

source websitesconf.sh

ids="$(seq -w $websites_seq_start $websites_seq_end)"

for id in $ids
do
	my_user="site${id}"

	echo "updating password for $my_user"

	# account
	echo "$my_user:$user_base_passwd$my_user" | chpasswd

	# database
	echo "GRANT USAGE ON *.* TO '$my_user'@'%' IDENTIFIED BY '$mysql_passwd_base$my_user';" | mysql
done

systemctl restart sshd

