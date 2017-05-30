#!/bin/bash
# this is a setup scripts for nginx
# author: luoning
# date: 09/05/2014

# setup nginx

NGINX_PATH_7=http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
NGINX_PATH_6=http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm

print_hello(){
	echo "==========================================="
	echo "$1 nginx for TeamTalk"
	echo "==========================================="
}

check_user() {
	if [ $(id -u) != "0" ]; then
    	echo "Error: You must be root to run this script, please use root to install nginx"
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
	ps -ef | grep -v 'grep' | grep nginx
	if [ $? -eq 0 ]; then
		echo "Error: nginx is running."
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

install_nginx() {
	#yum -y install yum-fastestmirror
	clean_yum
	CENTOS_VERSION=$(less /etc/redhat-release)

	if [[ $CENTOS_VERSION =~ "7" ]]; then
		rpm -ivh $NGINX_PATH_7
	else
		rpm -ivh $NGINX_PATH_6
	fi
	yum -y install nginx
	if [ $? -eq 0 ]; then
  		echo "yum install nginx successed";
	else
  		echo "Error: yum install nginx failed";
  		exit 1;
	fi
	service nginx start
	if [ $? -eq 0 ]; then
  		echo "test to start nginx successed";
	else
  		echo "Error: test to stop nginx failed";
  		exit 1;
	fi
	service nginx stop
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
		install_nginx
		;;
	*)
		print_help
		;;
esac



