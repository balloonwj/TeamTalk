#!/bin/bash
# this is a setup scripts for web
# author: luoning
# date: 09/04/2014

# setup web
PHP_WEB=tt
PHP_WEB_SETUP_PATH=/var/www/html
PHP_DB_CONF=database.php
PHP_MSFS_CONF=config.php
PHP_DB_CONF_PATH=$PHP_WEB_SETUP_PATH/$PHP_WEB/application/config
PHP_NGINX_CONF=im.com.conf
PHP_NGINX_CONF_PATH=/etc/nginx/conf.d

print_hello(){
	echo "==========================================="
	echo "$1 im web for TeamTalk"
	echo "==========================================="
}

check_user() {
	if [ $(id -u) != "0" ]; then
    	echo "Error: You must be root to run this script, please use root to install im_web"
    	exit 1
	fi
}

check_os() {
	OS_VERSION=$(less /etc/redhat-release)
	OS_BIT=$(getconf LONG_BIT)
	#echo "$OS_VERSION, $OS_BIT bit..." 
	if [[ $OS_VERSION =~ "CentOS" ]]; then
		if [ $OS_BIT == 64 ]; then
			return 0
		else
			echo "Error: OS must be CentOS 64bit to run this script."
			exit 1
		fi
	else
		echo "Error: OS must be CentOS 64bit to run this script."
		exit 1
	fi
}

build_web(){
	if [ -d $PHP_WEB ]; then
		echo "$PHP_WEB has existed."
	else
		unzip $PHP_WEB.zip
		if [ $? -eq 0 ]; then
			echo "unzip $PHP_WEB successed."
		else
			echo "Error: unzip $PHP_WEB failed."
		return 1
		fi
	fi

	set -x
	mkdir -p $PHP_WEB_SETUP_PATH
	cp -r $PHP_WEB/ $PHP_WEB_SETUP_PATH
	cp ./conf/$PHP_DB_CONF $PHP_DB_CONF_PATH/
	cp ./conf/$PHP_MSFS_CONF $PHP_DB_CONF_PATH/
	set +x

	if [ -f $PHP_NGINX_CONF_PATH/default.conf ]; then
		rm $PHP_NGINX_CONF_PATH/default.conf
		echo "remove $PHP_NGINX_CONF_PATH/default.conf successed."
	fi
	set -x
	cp ./conf/$PHP_NGINX_CONF $PHP_NGINX_CONF_PATH/
	chmod -R 777 $PHP_WEB_SETUP_PATH/$PHP_WEB/
	set +x
	service nginx stop
	service nginx start
	return 0
}

print_help() {
	echo "Usage: "
	echo "  $0 check --- check environment"
	echo "  $0 install --- check & run scripts to install"
}

case $1 in
	check)
		print_hello $1
		check_user
		check_os
		;;
	install)
		print_hello $1
		check_user
		check_os
		build_web
		;;
	*)
		print_help
		;;
esac


