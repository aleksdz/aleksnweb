#!/bin/bash
dotnet run --project /var/aleksnweb/WebServer/WebServer.fsproj > >(logger -p user.info) 2> >(logger -p user.warn)