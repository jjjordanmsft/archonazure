#!/bin/bash

case "$1" in
	desc)
		echo Create customized builder container
		;;
	build)
		# We could check for and skip this, but then we'd probably screw things up if
		# we needed to add a new dependency, so just rely on Docker build cache being ok.
		cd ${STEPSDIR}/builder
		docker build -t archbuilder:$ARCH_VERSION . || exit $?
		;;
	clean)
		;;
	*)
		echo Should be invoked by build script!
		exit 1
		;;
esac
