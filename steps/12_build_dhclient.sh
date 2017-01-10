#!/bin/bash

case "$1" in
	desc)
		echo Build patched dhclient
		;;
	build)
		if [ ! -z "${REUSE_DHCLIENT}" ]; then
			echo export DHCLIENT=$REUSE_DHCLIENT >$STEP_OUT
			echo You supplied a dhclient package, skipping step.
			exit 0
		fi
		
		# Install build dependencies, dhclient source
		$DOCKER_EXEC pacman -S --noconfirm base-devel abs iproute2 || exit $?
		$DOCKER_EXEC abs extra/dhcp || exit $?
		
		# Create a user to perform the build, move source into that directory
		$DOCKER_EXEC useradd build || exit $?
		$DOCKER_EXEC bash -c "mkdir /work/dhclient && chown build:build /work/dhclient" || exit $?
		$DOCKER_EXEC su build -c "cp -R /var/abs/extra/dhcp/* /work/dhclient" || exit $?
		
		# Copy in the patch (and get permissions correct)
		cp -R $STEPSDIR/../dhclient $WORKDIR/dhclient-patch || exit $?
		$DOCKER_EXEC su build -c "cp /work/dhclient-patch/* /work/dhclient" || exit $?
		
		# Build
		$DOCKER_EXEC su build -c "cd /work/dhclient && makepkg -s -d --noconfirm --skippgpcheck" || exit $?
		pkg=$(basename $WORKDIR/dhclient/dhclient-*.pkg.tar.xz)
		
		echo export DHCLIENT=$WORKDIR/dhclient/$pkg >$STEP_OUT
		;;
	clean)
		$DOCKER_EXEC userdel build
		$DOCKER_EXEC rm -rf /work/dhclient /work/dhclient-patch
		;;
	*)
		echo Should be invoked by build script!
		exit 1
		;;
esac
