#!/bin/bash

if [ -z "$1" ]; then
	echo Specify a work directory
	exit 1
fi

# Get directories
mkdir -p $1/.status

pushd $1 >/dev/null
export WORKDIR=$(pwd)
popd >/dev/null
pushd $(dirname $0) >/dev/null
export SCRIPTDIR=$(pwd)
export STEPSDIR=${SCRIPTDIR}/steps
export UTILSDIR=${STEPSDIR}/utils
export UTILDIR=${UTILSDIR}

step_number()
{
	echo $1 | cut -d _ -f 1 | sed 's/^0*//'
}

steps=$(ls steps | grep -v "~" | sort)
revsteps=$(ls steps | grep -v "~" | sort -r)

if [ -e "$WORKDIR/.status/step" ]; then
	REC_STEP=$(cat $WORKDIR/.status/step)
else
	REC_STEP=0
fi

if [ -z "$2" ]; then
	START_STEP=$(($REC_STEP + 1))
else
	START_STEP=$2
fi

# Install environments in forward-order
for i in $steps ; {
	envfile="$WORKDIR/.status/$(step_number $i).env"
	if [ -e "$envfile" ]; then
		source $envfile
	fi
}

### Cleanup before running anything

# Clean up in reverse order
for i in $revsteps ; do
	clean_step=$(step_number $i)
	if (($clean_step <= $REC_STEP)) && (($clean_step > $START_STEP)) ; then
		echo "====> Cleaning step $clean_step :: $(bash $SCRIPTDIR/steps/$i desc)"
		/bin/bash $SCRIPTDIR/steps/$i clean
	fi
done

# Run in forward order
for i in $steps ; do
	run_step=$(step_number $i)
	if (($run_step >= $START_STEP)) ; then
		echo "====> Executing step $run_step :: $(bash $SCRIPTDIR/steps/$i desc)"
		export STEP_OUT="$WORKDIR/.status/$run_step.env"
		cd $WORKDIR
		/bin/bash $SCRIPTDIR/steps/$i build
		result=$?
		if [ -e $STEP_OUT ]; then
			source $STEP_OUT
		fi
		if [ "$result" -ne "0" ]; then
			echo "====> Step $run_step FAILED with result $result"
			/bin/bash $SCRIPTDIR/steps/$i clean
			exit $result
		fi
		echo $run_step >$WORKDIR/.status/step
	fi
done
