#!/bin/bash

case "$1" in
	desc)
		echo Start Archlinux container
		;;
	build)
		DOCKER_ID=$(docker run -dt --privileged -v ${WORKDIR}:/work archbuilder:${ARCH_VERSION} /bin/bash)
		echo export DOCKER_ID=${DOCKER_ID} >$STEP_OUT
		printf "export DOCKER_EXEC=\\\"docker exec -it ${DOCKER_ID}\\\"\n" >>$STEP_OUT
		
		echo Updating container
		docker exec -it $DOCKER_ID pacman -Syu --noconfirm
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
