#!/bin/bash

goversion=1.16

checkgov() {
	go version | grep $goversion
}

# Install Go into the correct directory
function install_go() {
        wget https://dl.google.com/go/$1

	sudo rm -rf $s
        sudo installer -pkg ./$1 -target /
	rm ./$1
}

function check() {
	if [ $1 -ne 0 ]; then
		exit 0
	fi
}

echo 'sudo apt-get update'
sudo apt-get -y update
check $?

echo 'sudo apt-get upgrade'
sudo apt-get -y upgrade
check $?

which go>/dev/null
if [ $? -ne 0 ]; then
        echo "Installing Go"
        install_go_linux "go$goversion.linux-arm64.tar.gz" "/usr/local"
        check $?
fi

checkgov
if [ $? -ne 0 ]; then
        echo "Upgrading Go"
        sudo rm -rf /usr/local/go
        install_go_linux "go$goversion.linux-arm64.tar.gz" "/usr/local"
        check $?
fi

cat ~/.bashrc | grep /usr/local/go/bin
if [ $? -ne 0 ]; then
    echo "Adding go to the path variable"
    echo "export PATH=$PATH:/usr/local/go/bin:~/bin" >> ~/.bashrc
fi