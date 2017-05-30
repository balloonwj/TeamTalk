#!/bin/bash
# this is a setup scripts for redis
# author: luoning
# date: 08/30/2014

# setup redis
export MAKE=make
REDIS=redis-2.8.19
REDIS_DOWNLOAD_PATH=http://download.redis.io/releases/$REDIS.tar.gz
REDIS_CONF_PATH=/usr/local/etc
REDIS_CONF=redis.conf
REDIS_SERVER_PATH=/usr/local/bin
REDIS_SERVER=redis-server

print_hello(){
	echo "==========================================="
	echo "$1 redis for TeamTalk"
	echo "==========================================="
}

check_user() {
	if [ $(id -u) != "0" ]; then
    	echo "Error: You must be root to run this script, please use root to install redis"
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

check_run() {
	ps -ef | grep -v 'grep' | grep redis-server
	if [ $? -eq 0 ]; then
		echo "Error: redis is running."
		exit 1
	fi
}

download() {
	if [ -f "$1" ]; then
		echo "$1 existed."
	else
		echo "$1 not existed, begin to download..."
		wget $2
		if [ $? -eq 0 ]; then
			echo "download $1 successed"
		else
			echo "Error: download $1 failed"
			return 1
		fi
	fi
	return 0
}

run_redis() {
	PROCESS=$(pgrep redis)
	if [ -z "$PROCESS" ]; then 
		echo "no redis is running..." 
	else 
		echo "Warning: redis is running"
		return 0
	fi

	cd conf/
	if [ -f "$REDIS_CONF" ]; then
		set -x
		cp -f $REDIS_CONF $REDIS_CONF_PATH/
		set +x
		cd ../
	else
		cd ../
		echo "Error: $REDIS_CONF not existed."
		return 1
	fi
	
	

	$REDIS_SERVER_PATH/$REDIS_SERVER $REDIS_CONF_PATH/$REDIS_CONF
	if [ $? -eq 0 ]; then
		echo "start redis successed."
	else
		echo "Error: start redis failed."
		return 1
	fi
}

build_redis() {
	download $REDIS.tar.gz $REDIS_DOWNLOAD_PATH
	if [ $? -eq 1 ]; then
		return 1
	fi

	tar xzf $REDIS.tar.gz
	cd $REDIS
	$MAKE
	if [ $? -eq 0 ]; then
		echo "make redis successed"
	else
		echo "Error: make redis failed"
		return 1
	fi

	$MAKE install
	if [ $? -eq 0 ]; then
		echo "install redis successed"
	else
		echo "Error: install redis failed"
		return 1
	fi
	cd ..
}

build_all() {
	build_redis
	if [ $? -eq 0 ]; then
		echo "build redis successed."
	else
		echo "Error: build redis failed."
		exit 1
	fi

	run_redis
	if [ $? -eq 0 ]; then
		echo "run redis successed."
	else
		echo "Error: run redis failed."
		exit 1
	fi
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
		check_run
		;;
	install)
		print_hello $1
		check_user
		check_os
		check_run
		build_all
		;;
	*)
		print_help
		;;
esac



