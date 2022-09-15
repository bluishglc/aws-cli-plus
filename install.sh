#!/bin/bash

# Run the below commands as root
if [ "$(whoami)" != "root" ]; then
    echo "Run me as [ root ] user!"
    exit 1
fi

PROJECT_HOME="$(
    cd "$(dirname $(readlink -nf "$0"))"/..
    pwd -P
)"

INSTALL_HOME="/opt/${PROJECT_HOME##*/}"

echo "install cli ..."
rm -rf $INSTALL_HOME
mkdir -p $INSTALL_HOME
cp -r $PROJECT_HOME/* $INSTALL_HOME/*

# create shortcuts for cli
echo "create shortcuts for cli ..."
sudo yum list installed jq &> /dev/null
if [ "$?" != "0" ]; then sudo yum -y install jq; fi
sudo rm -f "/usr/bin/aws-cli-plus"
sudo ln -s "$INSTALL_HOME/aws-cli-plus.sh" "/usr/bin/aws-cli-plus"

echo "done!"