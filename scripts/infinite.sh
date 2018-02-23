#!/bin/bash

whoami
hostname
while true
do
	echo "$(date +%Y-%m-%d_%H-%M-%S): Running my infinit script in slurm!"
	sleep 10
done

