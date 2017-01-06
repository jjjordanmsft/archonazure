#!/bin/bash

case "$1" in
	desc)
		echo Build ArchLinux Docker image
		;;
	build)
		# Skip past long downloads/steps on rebuild.
		if [ ! -z "${REUSE_DOCKER_IMAGE}" ]; then
			echo Skipping...
			exit 0
		fi
		
		cd archlinux-docker
		echo Running tar_fix
		python3 tar_fix.py --input=../${ARCH_IMG} --output=bootstrap.tar.gz || exit $?
		echo Running docker build
		docker build -t archlinux:$ARCH_VERSION . --build-arg architecture=${ARCHITECTURE:-x86_64}
		docker tag archlinux:$ARCH_VERSION archlinux:latest
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
