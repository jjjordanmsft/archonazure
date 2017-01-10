#!/bin/bash

case "$1" in
	desc)
		echo Configure target system
		;;
	build)
		# First copy bootstrap scripts
		mkdir -p provision
		cp ${STEPSDIR}/target/* $DHCLIENT provision
		
		# Write settings
		echo export LOOP_DEV=${LOOP_DEV} > provision/settings.sh
		echo export LANG=${TARGET_LANG} >> provision/settings.sh
		echo export DHCLIENT=$(basename $DHCLIENT) >> provision/settings.sh
		
		$DOCKER_EXEC cp -R /work/provision /mnt/opt || exit $?
		$DOCKER_EXEC /bin/bash -c "chmod 755 /mnt/opt/provision/*.sh" || exit $?
		$DOCKER_EXEC arch-chroot /mnt /opt/provision/configure.sh || exit $?
		$DOCKER_EXEC /mnt/opt/provision/finalize.sh || exit $?
		
		# Remove provisioning scripts
		$DOCKER_EXEC rm -rf /mnt/opt/provision
		;;
	clean)
		;;
	*)
		echo Should be invoked by build script!
		exit 1
		;;
esac
