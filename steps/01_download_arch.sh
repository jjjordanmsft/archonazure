#!/bin/bash

case "$1" in
	desc)
		echo Download ArchLinux bootstrapper
		;;
	build)
		tstamp=$(date +%Y.%m.01)
		ARCH_IMG=archlinux-bootstrap-$tstamp-x86_64.tar.gz
		wget http://archive.archlinux.org/iso/$tstamp/$ARCH_IMG || exit $?
		echo export ARCH_VERSION=${tstamp} >$STEP_OUT
		echo export ARCH_IMG=${ARCH_IMG} >>$STEP_OUT
		;;
	clean)
		rm -rf archlinux-bootstrap-*
		;;
	*)
		echo Should be invoked by build script!
		exit 1
		;;
esac
