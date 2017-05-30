#!/bin/bash

build() {
	echo "#ifndef __VERSION_H__" > base/version.h
	echo "#define __VERSION_H__" >> base/version.h
	echo "#define VERSION \"$1\"" >> base/version.h
	echo "#endif" >> base/version.h

    if [ ! -d lib ]
    then
        mkdir lib
    fi

	cd base
    cmake .
	make
    if [ $? -eq 0 ]; then
        echo "make base successed";
    else
        echo "make base failed";
        exit;
    fi
    if [ -f libbase.a ]
    then
        cp libbase.a ../lib/
    fi
    cd ../slog
    cmake .
    make
    if [ $? -eq 0 ]; then
        echo "make slog successed";
    else
        echo "make slog failed";
        exit;
    fi
    mkdir ../base/slog/lib
    cp slog_api.h ../base/slog/
    cp libslog.so ../base/slog/lib/
    cp -a lib/liblog4cxx* ../base/slog/lib/

    cd ../login_server
    cmake .
	make
    if [ $? -eq 0 ]; then
        echo "make login_server successed";
    else
        echo "make login_server failed";
        exit;
    fi

	cd ../route_server
    cmake .
	make
    if [ $? -eq 0 ]; then
        echo "make route_server successed";
    else
        echo "make route_server failed";
        exit;
    fi

	cd ../msg_server
    cmake .
	make
    if [ $? -eq 0 ]; then
        echo "make msg_server successed";
    else
        echo "make msg_server failed";
        exit;
    fi

    cd ../http_msg_server
    cmake .
    make
    if [ $? -eq 0 ]; then
        echo "make http_msg_server successed";
    else
        echo "make http_msg_server failed";
        exit;
    fi

    cd ../file_server
    cmake .
    make
    if [ $? -eq 0 ]; then
        echo "make file_server successed";
    else
        echo "make file_server failed";
        exit;
    fi

    cd ../push_server
    cmake .
    make
    if [ $? -eq 0 ]; then
        echo "make push_server successed";
    else
        echo "make push_server failed";
        exit;
    fi

    cd ../tools
    make
    if [ $? -eq 0 ]; then
        echo "make tools successed";
    else
        echo "make tools failed";
        exit;
    fi

    cd ../db_proxy_server
    cmake .
    make
    if [ $? -eq 0 ]; then
        echo "make db_proxy_server successed";
    else
        echo "make db_proxy_server failed";
        exit;
    fi

    cd ../msfs
    cmake .
    make
    if [ $? -eq 0 ]; then
        echo "make msfs successed";
    else
        echo "make msfs failed";
        exit;
    fi
}

clean() {
	cd base
	make clean
	cd ../login_server
	make clean
	cd ../route_server
	make clean
	cd ../msg_server
	make clean
	cd ../http_msg_server
    make clean
	cd ../file_server
    make clean
    cd ../push_server
    make clean
	cd ../db_proxy_server
	make clean
    cd ../push_server
    make clean
}

print_help() {
	echo "Usage: "
	echo "  $0 clean --- clean all build"
	echo "  $0 version version_str --- build a version"
}

case $1 in
	clean)
		echo "clean all build..."
		clean
		;;
	version)
		if [ $# != 2 ]; then 
			echo $#
			print_help
			exit
		fi

		echo $2
		echo "build..."
		build $2
		;;
	*)
		print_help
		;;
esac
