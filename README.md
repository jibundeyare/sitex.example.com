# Batch creation of web sites

This set of scripts creates a number of user accounts, virtual hosts and mysql users and databases.

## Web site creation script

The `websitesmk.sh` script creates :

- a user
- a home directory
- a database user
- a database
- a dedicated Apache2 virtual host
- a dedicated PHP FPM pool

All names have the following common base : `siteXX` where XX is an integer from 1 to 30 :

- the users are `siteXX`
- the home directories are `/home/siteXX`
- the databases users are `siteXX`
- the databases are `siteXX`
- the dedicated Apache2 virtual hosts are if the form `siteXX.example.com`
- the dedicated PHP FPM pools are `siteXX`

## Prerequisites

- Linux system
- Apache 2.4
- MariaDB 15.x
- PHP 7.x FPM

## Configuration

Copy `websitesconf.sh.dist` as `websitesconf.sh` and choose appropriate values.

### Domain name

Edit `websitesconf.sh` and change the value of `domain_name` to choose the domain name of the sites you want to create.

### Number of web sites

Edit `websitesconf.sh` and change the value of `websites_count` to choose the number of sites you want to create.

### Passwords

Edit `websitesconf.sh` and change the value of `user_base_passwd` and `mysql_passwd_base` to choose the password base for the user account and the mysql user.

### Virtual host

The `template-vhost.conf` is a template file for Apache2 vhost.
The `{my_user}` keyword is replaced with a value generated by the `websitesmk.sh` script.

The `000-default.conf` is the default virtual host file shipped with Apache2.
It is not used by the project but is a good starting point.

### PHP FPM pool

The `template-pool.conf` is a template file for PHP FPM pool.
The `{my_user}` keyword is replaced with a value generated by the `websitesmk.sh` script.

The `www.conf` is the default pool file shipped with PHP FPM.
It is not used by the project but is a good starting point.

### HTML index file

The `template-index.html` is a template file for HTML index page.
The `{my_user}` keyword is replaced with a value generated by the `websitesmk.sh` script.

### PHP test file

The `template-test.php` is a template file for PHP test page.
The `{my_user}` keyword is not used.

## Usage

To create web sites:

	sudo ./websitesmk.sh
	sudo ./websitespwd.sh

To change passwords:

	sudo ./websitespwd.sh

To remove web sites;

	sudo ./websitesrm.sh

