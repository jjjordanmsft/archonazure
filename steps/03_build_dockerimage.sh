#!/bin/bash

case "$1" in
	desc)
		echo Build ArchLinux Docker image
		;;
	build)
		cd archlinux-docker
		python3 tar_fix.py --input=../${ARCH_IMG} --output=bootstrap.tar.gz || exit $?
		docker build -t archlinux . --build-arg architecture=x86_64
		;;
	clean)
		cd archlinux-docker
		rm -rf bootstrap.tar.gz
		docker rmi archlinux
		;;
	*)
		echo Should be invoked by build script!
		exit 1
		;;
esac
