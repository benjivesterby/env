#!/bin/bash

if [ -z "$1" ]
then
      echo "\$1 is empty. Must be an user.name value"
      exit 1
fi

if [ -z "$2" ]
then
      echo "\$2 is empty. Must be an email address"
      exit 1
fi

if [ -z "$3" ]
then
      echo "\$3 is empty. Must be an environment git repo"
      exit 1
fi


sudo apt-get install git curl wget

folder="${HOME}/src"
if [ ! -d $folder ]; then
	echo "Creating ~/src directory"
	mkdir $folder
fi

file="${HOME}/.ssh/id_rsa"
if [ ! -f $file ]; then
	ssh-keygen -t rsa -b 4096 -C "$2"
fi

git config --global user.name "$1"
git config --global user.email $2

# set the signing key if the user supplied it
if [ -z "$4" ]
then
	git config --global user.signingkey $4 
fi


folder="${HOME}/src/env"
if [ ! -d $folder ]; then
	echo "Cloning environment repository"
	git clone $3 ~/src/env
fi

~/src/env/env.sh -i
