#!/bin/bash

if [[ "$1" == "" ]] 
then 
	echo "Must pass env filename"
	exit 1
fi
cp -fR ~/.config/nvim .
cp -f ~/$1 ./$1
cp -f ~/.tmux.conf ./

