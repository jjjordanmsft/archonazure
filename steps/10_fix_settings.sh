#!/bin/bash

case "$1" in
	desc)
		echo Fix settings on image
		;;
	build)
		# Fix fstab (currently thinks it's loop!)
		
		# Fix kernel parameters
		;;
	clean)
		;;
	*)
		echo Should be invoked by build script!
		exit 1
		;;
esac
