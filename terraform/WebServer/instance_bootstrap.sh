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

# Open Internet Ports for External Connectivity
iptables -A INPUT -p tcp --dport 80 --jump ACCEPT
iptables -A INPUT -p tcp --dport 443 --jump ACCEPT
iptables-save

echo "git clone https://github.com/zaersx/aleksnweb.git" >> /etc/init.d/web_server_start.sh
echo "sudo dotnet run --project aleksnweb/WebServer/WebServer.fsproj" >> /etc/init.d/web_server_start.sh
cmod +x /etc/init.d/web_server_start.sh
sudo update-rc.d web_server_start.sh defaults