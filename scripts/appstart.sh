#!/bin/bash

# Service configuration file
cp WebServer.service /etc/systemd/system/WebServer.service

# Open internet ports for WebServer connectivity
iptables -A INPUT -p tcp --dport 80 --jump ACCEPT
iptables -A INPUT -p tcp --dport 443 --jump ACCEPT
iptables-save

# Autostart service on boot and start service now
systemctl enable WebServer
systemctl start WebServer