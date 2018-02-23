#!/bin/bash

## Print out username and name of node
whoami
hostname

## Set up constants and variables

# Constants
SECONDS_TO_SLEEP=1
#SECONDS_TILL_STOP=60*5
SECONDS_TILL_STOP=5

#Variables
seconds_count=0

# Loop until seconds_count reaches or exceed SECONDS_TILL_STOP
while true
do
	# Echo current time and script being run
	echo "$(date +%Y-%m-%d_%H-%M-%S): Running $0 in slurm!"
	# Add to seconds_count
	((seconds_count+=$SECONDS_TO_SLEEP))
	sleep $SECONDS_TO_SLEEP
	# Exit if we waited long enough
	if (($seconds_count >= $SECONDS_TILL_STOP )); then
		echo "$(date +%Y-%m-%d_%H-%M-%S): Finished script in $seconds_count seconds!"
		exit
	fi
done

