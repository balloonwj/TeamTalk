#!/bin/bash
# this is a setup scripts for php
# author: luoning
# date: 09/06/2014

# setup php

PHP=php-5.6.6
PHP_DOWNLOAD_PATH=http://cn2.php.net/distributions/$PHP.tar.gz
INSTALL_DIR=/usr/local/php5

PHP_FPM_CONF=php-fpm.conf
PHP_INI=php.ini
MAKE=make
CPU_NUM=`cat /proc/cpuinfo | grep processor | wc -l`

print_hello(){
	echo "==========================================="
	echo "$1 php for TeamTalk"
	echo "==========================================="
}

check_user() {
	if [ $(id -u) != "0" ]; then
    	echo "Error: You must be root to run this script, please use root to install php"
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
	ps -ef | grep -v 'grep' | grep php-fpm
	if [ $? -eq 0 ]; then
		echo "Error: php-fpm is running."
		exit 1
	fi
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


download() {
	if [ -f "$1" ]; then
		echo "$1 existed."
	else
		echo "$1 not existed, begin to download..."
		wget $2
		if [ $? -eq 0 ]; then
			echo "download $1 successed";
		else
			echo "Error: download $1 failed";
			return 1;
		fi
	fi
	return 0
}

# building php
build_php() {
	gunzip -c $PHP.tar.gz | tar xf -
	cd $PHP
	./configure --prefix=$INSTALL_DIR \
		  --with-config-file-path=$INSTALL_DIR/etc \
	    --enable-fpm \
	    --enable-gd-native-ttf \
	    --with-mysql=mysqlnd \
	    --with-mysqli=mysqlnd \
	    --with-pdo-mysql=mysqlnd \
	    --with-curl	\
	    #--with-apxs2 \
	    --with-zlib \
	    --with-zlib-dir \
	    --with-libxml-dir \
	    --with-freetype-dir \
	    --with-jpeg-dir \
	    --with-png-dir \
	    --with-gd 
	    
	$MAKE -j $CPU_NUM
	if [ $? -eq 0 ]; then
	  echo "make php successed";
	else
	  echo "Error: make php failed";
	  return 1;
	fi
	$MAKE install
	if [ $? -eq 0 ]; then
	  echo "install php successed";
	else
	  echo "Error: install php failed";
	  return 1;
	fi
	cd ..
	return 0
}

# modify and copy php.ini
modify_php() {
	set -x
	cp  ./conf/$PHP_FPM_CONF  $INSTALL_DIR/etc/$PHP_FPM_CONF
	chmod 755 $INSTALL_DIR/etc/$PHP_FPM_CONF
	cp  ./conf/$PHP_INI $INSTALL_DIR/etc/$PHP_INI
	chmod 755 $INSTALL_DIR/etc/$PHP_INI

	killall php-fpm
	$INSTALL_DIR/sbin/php-fpm
	set +x
	netstat -antpl

}

build_zlib() {
	clean_yum

	yum -y install zlib-devel
	if [ $? -eq 0 ]; then
		echo "yum install zlib-devel successed."
	else
		echo "Error: yum install zlib-devel failed."
		return 1;
	fi
}

build_jpeg() {
	clean_yum
	yum -y install libjpeg-devel
	if [ $? -eq 0 ]; then
		echo "yum install libjpeg-devel successed."
	else
		echo "Error: yum install libjpeg-devel failed."
		return 1;
	fi
}

build_freetype() {
	clean_yum
	yum -y install freetype-devel
	if [ $? -eq 0 ]; then
		echo "yum install freetype-devel successed."
	else
		echo "Error: yum install freetype-devel failed."
		return 1;
	fi
}

build_png() {
	clean_yum
	yum -y install libpng-devel
	if [ $? -eq 0 ]; then
		echo "yum install libpng-devel successed."
	else
		echo "Error: yum install libpng-devel failed."
		return 1;
	fi
}


build_gd() {
	clean_yum
	yum -y install php-gd
	if [ $? -eq 0 ]; then
		echo "yum install php-gd successed."
	else
		echo "Error: yum install php-gd failed."
		return 1;
	fi
}

build_xml() {
	clean_yum
	yum -y install libxml2-devel
	if [ $? -eq 0 ]; then
		echo "yum install libxml2-devel successed."
	else
		echo "Error: yum install libxml2-devel failed."
		return 1;
	fi
}

build_curl() {
	clean_yum
	yum -y install curl-devel
	if [ $? -eq 0 ]; then
		echo "yum install curl-devel successed."
	else
		echo "Error: yum install curl-devel failed."
		return 1;
	fi
}

build_all()
{
	#yum -y install yum-fastestmirror

	build_zlib
	if [ $? -eq 0 ]; then
		echo "build zlib successed."
	else
		echo "Error: build zlib failed."
		exit 1
	fi

	build_jpeg
	if [ $? -eq 0 ]; then
		echo "build jpeg successed."
	else
		echo "Error: build jpeg failed."
		exit 1
	fi

	build_freetype
	if [ $? -eq 0 ]; then
		echo "build freetype successed."
	else
		echo "Error: build freetype failed."
		exit 1
	fi

	build_png
	if [ $? -eq 0 ]; then
		echo "build png successed."
	else
		echo "Error: build png failed."
		exit 1
	fi

	build_gd
	if [ $? -eq 0 ]; then
		echo "build gd successed."
	else
		echo "Error: build gd failed."
		exit 1
	fi

	build_xml
	if [ $? -eq 0 ]; then
		echo "build xml successed."
	else
		echo "Error: build xml failed."
		exit 1
	fi

	build_curl
	if [ $? -eq 0 ]; then
		echo "build curl successed."
	else
		echo "Error: build curl failed."
		exit 1
	fi

	download $PHP.tar.gz $PHP_DOWNLOAD_PATH
	if [ $? -eq 1 ]; then
  		exit 1;
	fi

	mkdir -p $INSTALL_DIR

	build_php
	if [ $? -eq 1 ]; then
		exit 1
	fi  
	modify_php
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
		print_hello	$1
		check_user
		check_os
		check_run
		build_all
		;;
	*)
		print_help
		;;
esac



