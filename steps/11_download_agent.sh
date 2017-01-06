#!/bin/bash

case "$1" in
	desc)
		echo Download Azure Linux Agent
		;;
	build)
		WAAGENT_REPO=https://github.com/jjjordanmsft/WALinuxAgent.git
		WAAGENT_BRANCH=arch-v2.2.2
		$DOCKER_EXEC git clone ${WAAGENT_REPO} /mnt/opt/walinuxagent || exit $?
		$DOCKER_EXEC bash -c "cd /mnt/opt/walinuxagent ; git checkout ${WAAGENT_BRANCH}" || exit $?
		$DOCKER_EXEC rm -rf /mnt/opt/walinuxagent/.git
		;;
	clean)
		$DOCKER_EXEC rm -rf /mnt/opt/walinuxagent
		;;
	*)
		echo Should be invoked by build script!
		exit 1
		;;
esac
