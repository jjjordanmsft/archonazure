#!/bin/bash

case "$1" in
	desc)
		echo Bootstrap image
		;;
	build)
		# First copy bootstrap scripts
		mkdir -p provision
		cp ${SCRIPTDIR}/target/* provision
		
		# Write settings
		echo export LOOP_DEV=${LOOP_DEV} > provision/settings.sh
		echo export LANG=${TARGET_LANG} >> provision/settings.sh
		
		$DOCKER_EXEC cp -R /work/provision /mnt/opt || exit $?
		$DOCKER_EXEC /bin/bash -c "chmod 755 /mnt/opt/provision/*.sh" || exit $?
		$DOCKER_EXEC arch-chroot /mnt /opt/provision/bootstrap.sh || exit $?
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
