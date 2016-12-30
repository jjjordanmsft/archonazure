#!/bin/bash

case "$1" in
	desc)
		echo Download Docker image build scripts
		;;
	build)
		git clone https://github.com/czka/archlinux-docker.git
		;;
	clean)
		rm -rf archlinux-docker
		;;
	*)
		echo Should be invoked by build script!
		exit 1
		;;
esac
