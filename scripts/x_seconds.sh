#!/bin/bash

# First param: total seconds to wait
# Second param: how many seconds to sleep in the loop

## Print out username and name of node
whoami
hostname

## Set up constants and variables

## Constants
# Set the first param, and default it to 5 minutes (300 seconds)
SECONDS_TILL_STOP=${1:-300}
# Set the second param, and default to 1 if not specified)
SECONDS_PER_ITERATION=${2:-1}

## Variables
seconds_count=0

# Loop until seconds_count reaches or exceed SECONDS_TILL_STOP
while true
do
	# Echo current time and script being run
	echo "$(date +%Y-%m-%d_%H-%M-%S): Running $0 in slurm!"
	# Add to seconds_count
	((seconds_count+=$SECONDS_PER_ITERATION))
	sleep $SECONDS_PER_ITERATION
	# Exit if we waited long enough
	if (($seconds_count >= $SECONDS_TILL_STOP )); then
		echo "$(date +%Y-%m-%d_%H-%M-%S): Finished script in $seconds_count seconds!"
		exit
	fi
done

