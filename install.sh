#!/bin/bash

wd=$(pwd)

mkdir /root/bin

apt-get update

apt-get install -y git curl

git clone --branch server https://github.com/benjivesterby/env.git

cd ./env

./env.sh -i
