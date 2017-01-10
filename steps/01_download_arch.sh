#!/bin/bash

case "$1" in
	desc)
		echo Download ArchLinux bootstrapper
		;;
	build)
		VERSION=$(python3 $UTILSDIR/latest_ver.py)
		ARCH_IMG=archlinux-bootstrap-$VERSION-x86_64.tar.gz
		
		echo export ARCH_VERSION=${VERSION} >$STEP_OUT
		echo export ARCH_IMG=${ARCH_IMG} >>$STEP_OUT
		
		# Check whether we've already built this Docker image
		if docker images | grep -E "^archlinux\s+$VERSION" >/dev/null ; then
			echo export REUSE_DOCKER_IMAGE=archlinux:$VERSION >>$STEP_OUT
			echo Found docker image for $VERSION, skipping build
			exit 0
		fi
		
		# Skip past long downloads/steps on rebuild (if specified by config file)
		if [ -z "${REUSE_DOCKER_IMAGE}" ]; then
			curl -o $WORKDIR/$ARCH_IMG https://archive.archlinux.org/iso/$VERSION/$ARCH_IMG || exit $?
			curl -o $WORKDIR/$ARCH_IMG.sig https://archive.archlinux.org/iso/$VERSION/$ARCH_IMG.sig || exit $?
			bash $UTILSDIR/verify_sig.sh $WORKDIR/$ARCH_IMG.sig || exit $?
		fi
		
		;;
	clean)
		rm -rf archlinux-bootstrap-*
		;;
	*)
		echo Should be invoked by build script!
		exit 1
		;;
esac
