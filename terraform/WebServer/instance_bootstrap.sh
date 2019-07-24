#!/usr/bin/env bash

# Enable MS Sources for Debian
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.asc.gpg
mv microsoft.asc.gpg /etc/apt/trusted.gpg.d/
wget -q https://packages.microsoft.com/config/debian/9/prod.list
mv prod.list /etc/apt/sources.list.d/microsoft-prod.list
chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg
chown root:root /etc/apt/sources.list.d/microsoft-prod.list

#Install Required Packages
apt-get --yes install apt-transport-https
apt-get update
apt-get --yes install dotnet-sdk-2.2
apt-get --yes install git
apt-get --yes install sysv-rc
apt-get --yes install logger

# CodeDeploy Agent
apt-get --yes install ruby
apt-get --yes install wget
wget https://aws-codedeploy-eu-west-1.s3.eu-west-1.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
sudo service codedeploy-agent start

# Open Internet Ports for External Connectivity
iptables -A INPUT -p tcp --dport 80 --jump ACCEPT
iptables -A INPUT -p tcp --dport 443 --jump ACCEPT
iptables-save

