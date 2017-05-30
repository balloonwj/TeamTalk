#!/bin/bash
case $1 in
    clean)
        echo "clean all build..."
        rm -rf CMakeFiles
        rm -rf Makefile
        rm -rf CMakeCache.txt
        rm -rf cmake_install.cmake
        rm -rf libsecurity.a
        ;;
    *)
        cmake ../src
        make
        OS=`uname -s`
        if [ $OS" " ==  "Darwin"" " ];
        then
            cp libsecurity.a ../lib/mac/
        else
            cp libsecurity.a ../lib/unix/
        fi
        ;;
esac

