#!/bin/bash

#
# pid of its parent process
# reference BASHPID, $$, pidof

echo $PPID

echo $BASHPID

echo $$

pidof $0	# pid of all shells, only work in CLI(command line)
