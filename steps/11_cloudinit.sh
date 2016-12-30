#!/bin/bash

case "$1" in
	desc)
		echo Run cloudinit
		;;
	build)
		;;
	clean)
		;;
	*)
		echo Should be invoked by build script!
		exit 1
		;;
esac
