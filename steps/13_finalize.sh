#!/bin/bash

case "$1" in
	desc)
		echo Finalize image
		;;
	build)
		$DOCKER_EXEC qemu-img convert -f raw -O vpc -o subformat=fixed,force_size /work/rawdisk /work/ArchLinux-${ARCH_VERSION}.vhd
		;;
	clean)
		rm -rf ArchLinux-${ARCH_VERSION}.vhd
		;;
	*)
		echo Should be invoked by build script!
		exit 1
		;;
esac
