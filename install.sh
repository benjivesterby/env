#!/bin/bash

wd=$(pwd)

mkdir /root/bin

apt-get update

apt-get install -y git curl

# remove the subscription notice from proxmox
# https://johnscs.com/remove-proxmox51-subscription-notice/
sed -Ezi.bak "s/(Ext.Msg.show\(\{\s+title: gettext\('No valid sub)/void\(\{ \/\/\1/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js && systemctl restart pveproxy.service

git clone --branch server https://github.com/benjivesterby/env.git

cd ./env

./env.sh -i
