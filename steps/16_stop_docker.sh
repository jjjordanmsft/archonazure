#!/bin/bash

case "$1" in
	desc)
		echo Stop docker container
		;;
	build)
		docker stop ${DOCKER_ID}
		docker rm ${DOCKER_ID}
		;;
	clean)
		;;
	*)
		echo Should be invoked by build script!
		exit 1
		;;
esac
