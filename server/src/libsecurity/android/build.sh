#!/bin/bash
case $1 in
    clean)
        echo "clean all build..."
        ndk-build clean
        rm -rf bin
        rm -rf gen
        rm -rf obj
        rm -rf libs
        ;;
    *)
        ndk-build
        cp -rf libs ../lib/android/
        ;;
esac
