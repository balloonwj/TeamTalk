#!/bin/bash
# this is a setup scripts for TeamTalk
# author: luoning
# date: 09/05/2014

# setup TeamTalk

REDIS=redis
MYSQL=mariadb
NGINX_PHP=nginx_php
NGINX=nginx
PHP=php

IM_WEB=im_web
IM_SERVER=im_server
IM_DB_PROXY=im_db_proxy
CUR_DIR=

SETUP_PROGRESS=setup.progress
REDIS_SETUP_BEGIN=0
REDIS_SETUP_SUCCESS=0
MYSQL_SETUP_BEGIN=0
MYSQL_SETUP_SUCCESS=0
NGINX_SETUP_BEGIN=0
NGINX_SETUP_SUCCESS=0
PHP_SETUP_BEGIN=0
PHP_SETUP_SUCCESS=0
IM_WEB_SETUP_BEGIN=0
IM_WEB_SETUP_SUCCESS=0
IM_SERVER_SETUP_BEGIN=0
IM_SERVER_SETUP_SUCCESS=0


# Check if user is root
check_user() {
	if [ $(id -u) != "0" ]; then
    	echo "Error: You must be root to run this script, please use root to install im"
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

print_hello() {
	echo "========================================================================="
	echo "TeamTalk V1.0 for CentOS Linux Server, Written by Luoning"
	echo "========================================================================="
	echo "A tool to auto-compile & install TeamTalk on Linux "
	echo ""
	echo "For more information please visit https://github.com/mogutt/TTAutoDeploy/"
	echo "========================================================================="
}

get_cur_dir() {
	# Get the fully qualified path to the script
	case $0 in
    	/*)
        	SCRIPT="$0"
        	;;
    	*)
        	PWD_DIR=$(pwd);
        	SCRIPT="${PWD_DIR}/$0"
        	;;
	esac
	# Resolve the true real path without any sym links.
	CHANGED=true
	while [ "X$CHANGED" != "X" ]
	do
    	# Change spaces to ":" so the tokens can be parsed.
    	SAFESCRIPT=`echo $SCRIPT | sed -e 's; ;:;g'`
    	# Get the real path to this script, resolving any symbolic links
    	TOKENS=`echo $SAFESCRIPT | sed -e 's;/; ;g'`
    	REALPATH=
    	for C in $TOKENS; do
        	# Change any ":" in the token back to a space.
        	C=`echo $C | sed -e 's;:; ;g'`
        	REALPATH="$REALPATH/$C"
        	# If REALPATH is a sym link, resolve it.  Loop for nested links.
        	while [ -h "$REALPATH" ] ; do
            	LS="`ls -ld "$REALPATH"`"
            	LINK="`expr "$LS" : '.*-> \(.*\)$'`"
            	if expr "$LINK" : '/.*' > /dev/null; then
                	# LINK is absolute.
                	REALPATH="$LINK"
            	else
                	# LINK is relative.
                	REALPATH="`dirname "$REALPATH"`""/$LINK"
            	fi
        	done
    	done

    	if [ "$REALPATH" = "$SCRIPT" ]
    	then
        	CHANGED=""
    	else
        	SCRIPT="$REALPATH"
    	fi
	done
	# Change the current directory to the location of the script
	CUR_DIR=$(dirname "${REALPATH}")
}

setup_begin() {
	# example:   redis start   
	echo "$1 start" >> $CUR_DIR/$SETUP_PROGRESS  
}

setup_success() {
	# example:   redis success  
	echo "$1 success" >> $CUR_DIR/$SETUP_PROGRESS  
}

get_setup_process() {
	if [ -f $CUR_DIR/$SETUP_PROGRESS ]; then
		while read line
		do

			case $line in 
				"$REDIS start")
					REDIS_SETUP_BEGIN=1
					;;
				"$REDIS success")
					REDIS_SETUP_SUCCESS=1
					;;
				"$MYSQL start")
					MYSQL_SETUP_BEGIN=1
					;;
				"$MYSQL success")
					MYSQL_SETUP_SUCCESS=1
					;;
				"$NGINX start")
					NGINX_SETUP_BEGIN=1
					;;
				"$NGINX success")
					NGINX_SETUP_SUCCESS=1
					;;
				"$PHP start")
					PHP_SETUP_BEGIN=1
					;;
				"$PHP success")
					PHP_SETUP_SUCCESS=1
					;;
				"$IM_WEB start")
					IM_WEB_SETUP_BEGIN=1
					;;
				"$IM_WEB success")
					IM_WEB_SETUP_SUCCESS=1
					;;
				"$IM_SERVER start")
					IM_SERVER_SETUP_BEGIN=1
					;;
				"$IM_SERVER success")
					IM_SERVER_SETUP_SUCCESS=1
					;;
				*)
					echo "unknown setup progress: $line "
					;;
			esac
		done < $CUR_DIR/$SETUP_PROGRESS
	fi
}

check_redis() {
	cd $REDIS
	chmod +x setup.sh
	./setup.sh check
	if [ $? -eq 0 ]; then
		cd $CUR_DIR
	else
		return 1
	fi
}

build_redis() {
	cd $REDIS
	chmod +x setup.sh
	setup_begin $REDIS
	./setup.sh install
	if [ $? -eq 0 ]; then
		setup_success $REDIS
		cd $CUR_DIR
	else
		return 1
	fi
	
}

check_mariadb() {
	cd $MYSQL
	chmod +x setup.sh
	./setup.sh check
	if [ $? -eq 0 ]; then
		cd $CUR_DIR
	else
		return 1
	fi
}

build_mariadb() {
	cd $MYSQL
	chmod +x setup.sh
	setup_begin $MYSQL
	./setup.sh install
	if [ $? -eq 0 ]; then
		setup_success $MYSQL
		cd $CUR_DIR
	else
		return 1
	fi
}

check_nginx() {
	cd $NGINX_PHP
	cd $NGINX
	chmod +x setup.sh
	./setup.sh check
	if [ $? -eq 0 ]; then
		cd $CUR_DIR
	else
		return 1
	fi
}

check_php() {
	cd $NGINX_PHP
	cd $PHP
	chmod +x setup.sh
	./setup.sh check
	if [ $? -eq 0 ]; then
		cd $CUR_DIR
	else
		return 1
	fi
}

build_nginx() {
	cd $NGINX_PHP

	cd $NGINX
	chmod +x setup.sh
	setup_begin $NGINX
	./setup.sh install
	if [ $? -eq 0 ]; then
		setup_success $NGINX
		cd $CUR_DIR
	else
		return 1
	fi
}

build_php() {
	cd $NGINX_PHP

	cd $PHP
	chmod +x setup.sh
	setup_begin $PHP
	./setup.sh install
	if [ $? -eq 0 ]; then
		setup_success $PHP
		cd $CUR_DIR
	else
		return 1
	fi
}

check_im_web() {
	cd $IM_WEB
	chmod +x setup.sh
	./setup.sh check
	if [ $? -eq 0 ]; then
		cd $CUR_DIR
	else
		return 1
	fi
}

build_im_web() {
	cd $IM_WEB
	chmod +x setup.sh
	setup_begin $IM_WEB
	./setup.sh install
	if [ $? -eq 0 ]; then
		setup_success $IM_WEB
		cd $CUR_DIR
	else
		return 1
	fi
}

check_im_server() {
	cd $IM_SERVER
	chmod +x setup.sh
	./setup.sh check
	if [ $? -eq 0 ]; then
		cd $CUR_DIR
	else
		return 1
	fi
}

build_im_server() {
	cd $IM_SERVER
	chmod +x setup.sh
	setup_begin $IM_SERVER
	./setup.sh install
	if [ $? -eq 0 ]; then
		setup_success $IM_SERVER
		cd $CUR_DIR
	else
		return 1
	fi
}

check_install() {
	local MODULE=$1
	local MODULE_SETUP_BEGIN=$2
	local MODULE_SETUP_SUCCESS=$3
	if [ $MODULE_SETUP_BEGIN = 1 ] && [ $MODULE_SETUP_SUCCESS = 1 ]; then
		echo "$MODULE has installed, skip check..."
		return 2
	else
		if [ $MODULE_SETUP_BEGIN = 1 ] && [ $MODULE_SETUP_SUCCESS = 0 ]; then
			echo "Warning: $MODULE has installed before, but failed by some reason, check/build again?(Y/N)"
			while read input
			do
				if [ $input = "Y" ] || [ $input = "y" ]; then
					return 0
				elif [ $input = "N" ] || [ $input = "n" ]; then
					return 1
				else
					echo "unknown input, try again please, check/build again?(Y/N)."
					continue
				fi
			done
		fi
	fi
	return 0
}

check_env() {
	local MODULE=$1
	echo "start to check $MODULE..."
	check_$MODULE
	if [ $? -eq 0 ]; then
		echo "check $MODULE successed."
	else
		echo "Error: check $MODULE failed, stop install."
		exit 1
	fi
}

check_module() {
	local MODULE=$1
	local MODULE_SETUP_BEGIN=$2
	local MODULE_SETUP_SUCCESS=$3
	check_install $MODULE $MODULE_SETUP_BEGIN $MODULE_SETUP_SUCCESS
	RET=$?
	if [ $RET -eq 0 ]; then
		check_env $MODULE
	elif [ $RET -eq 1 ]; then
		return 1
	fi
	return 0
}

check_all() {
	get_setup_process

	#redis
	check_module $REDIS $REDIS_SETUP_BEGIN $REDIS_SETUP_SUCCESS
	if [ $? -eq 1 ]; then
		exit 1
	fi
	
	#mysql
	check_module $MYSQL $MYSQL_SETUP_BEGIN $MYSQL_SETUP_SUCCESS
	if [ $? -eq 1 ]; then
		exit 1
	fi

	#nginx
	check_module $NGINX $NGINX_SETUP_BEGIN $NGINX_SETUP_SUCCESS
	if [ $? -eq 1 ]; then
		exit 1
	fi
	
	#php
	check_module $PHP $PHP_SETUP_BEGIN $PHP_SETUP_SUCCESS
	if [ $? -eq 1 ]; then
		exit 1
	fi

	#im_web
    check_module $IM_WEB $IM_WEB_SETUP_BEGIN $IM_WEB_SETUP_SUCCESS
    if [ $? -eq 1 ]; then
    	exit 1
    fi

	#im_server
    check_module $IM_SERVER $IM_SERVER_SETUP_BEGIN $IM_SERVER_SETUP_SUCCESS
    if [ $? -eq 1 ]; then
    	exit 1
    fi
	
	echo "Check TeamTalk successed, and you can install TeamTalk now."
}

clean_yum() {
	YUM_PID=/var/run/yum.pid
	if [ -f "$YUM_PID" ]; then
		set -x
		rm -f YUM_PID
		killall yum
		set +x
	fi
}

build_module() {
	local MODULE=$1
	local MODULE_SETUP_BEGIN=$2
	local MODULE_SETUP_SUCCESS=$3
	if [ $MODULE_SETUP_BEGIN = 1 ] && [ $MODULE_SETUP_SUCCESS = 1 ]; then
		echo "$MODULE has installed, skip build..."
	else
		echo "start to build $MODULE..."
		build_$MODULE
		if [ $? -eq 0 ]; then
			echo "build $MODULE successed."
		else
			echo "Error: build $MODULE failed, stop install."
			return 1
		fi
	fi
}

build_all() {
	clean_yum
	yum -y install yum
	if [ $? -eq 0 ]; then
		echo "update yum successed."
	else
		echo "update yum failed."
		exit 1
	fi

	#redis
	build_module $REDIS $REDIS_SETUP_BEGIN $REDIS_SETUP_SUCCESS
	if [ $? -eq 1 ]; then
		exit 1
	fi


	#mysql
	build_module $MYSQL $MYSQL_SETUP_BEGIN $MYSQL_SETUP_SUCCESS
	if [ $? -eq 1 ]; then
		exit 1
	fi

	#nginx
	build_module $NGINX $NGINX_SETUP_BEGIN $NGINX_SETUP_SUCCESS
	if [ $? -eq 1 ]; then
		exit 1
	fi

	#php
	build_module $PHP $PHP_SETUP_BEGIN $PHP_SETUP_SUCCESS
	if [ $? -eq 1 ]; then
		exit 1
	fi

	#im_web
    build_module $IM_WEB $IM_WEB_SETUP_BEGIN $IM_WEB_SETUP_SUCCESS
    if [ $? -eq 1 ]; then
    	exit 1
    fi

	#im_server
    build_module $IM_SERVER $IM_SERVER_SETUP_BEGIN $IM_SERVER_SETUP_SUCCESS
    if [ $? -eq 1 ]; then
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
		print_hello
		check_user
		check_os
		get_cur_dir
		check_all
		;;
	install)
		print_hello
		check_user
		check_os
		get_cur_dir
		check_all
		build_all
		;;
	*)
		print_help
		;;
esac



