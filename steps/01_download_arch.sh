#!/bin/bash

case "$1" in
	desc)
		echo Download ArchLinux bootstrapper
		;;
	build)
		VERSION=$(python3 $UTILSDIR/latest_ver.py)
		ARCH_IMG=archlinux-bootstrap-$VERSION-x86_64.tar.gz
		
		# Skip past long downloads/steps on rebuild
		if [ -z "${REUSE_DOCKER_IMAGE}" ]; then
			curl -o $WORKDIR/$ARCH_IMG https://archive.archlinux.org/iso/$VERSION/$ARCH_IMG || exit $?
			curl -o $WORKDIR/$ARCH_IMG.sig https://archive.archlinux.org/iso/$VERSION/$ARCH_IMG.sig || exit $?
			bash $UTILSDIR/verify_sig.sh $WORKDIR/$ARCH_IMG.sig || exit $?
		fi
		
		echo export ARCH_VERSION=${VERSION} >$STEP_OUT
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
