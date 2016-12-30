#!/bin/bash

case "$1" in
	desc)
		echo Start Archlinux container
		;;
	build)
		DOCKER_ID=$(docker run -dt --privileged -v ${WORKDIR}:/work archlinux /bin/bash)
		echo export DOCKER_ID=${DOCKER_ID} >$STEP_OUT
		echo export DOCKER_EXEC="docker exec -it ${DOCKER_ID}" >>$STEP_OUT
		;;
	clean)
		docker stop ${DOCKER_ID}
		docker rm ${DOCKER_ID}
		;;
	*)
		echo Should be invoked by build script!
		exit 1
		;;
esac
