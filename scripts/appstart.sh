#!/bin/bash

# Service configuration file
echo "[Unit]
Description=WebServer Service
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=1
User=admin
ExecStart=dotnet /var/aleksnweb/WebServer/WebServer.fsproj

[Install]
WantedBy=multi-user.target"
>> /etc/systemd/system/WebServer.service

# Open internet ports for WebServer connectivity
iptables -A INPUT -p tcp --dport 80 --jump ACCEPT
iptables-save

# Autostart service on boot and start service now
systemctl enable WebServer
systemctl start WebServer