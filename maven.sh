#!/bin/bash
wget https://dlcdn.apache.org/maven/maven-3/3.9.1/binaries/apache-maven-3.9.1-bin.zip
unzip apache-maven-3.9.1-bin.zip -d /opt
echo "export MAVEN_HOME=/opt/apache-maven-3.9.1;export PATH=\$MAVEN_HOME/bin:\$PATH" > /etc/profile.d/maven.sh
source /etc/profile.d/maven.sh
# make sure ec2-user also set MAVEN_HOME, only works after re-login as ec2-user
# not work for current ssh session!
sudo -i -u ec2-user source /etc/profile.d/maven.sh