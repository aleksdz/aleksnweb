#!/bin/bash
kill $(ps aux | grep 'WebServer.dll' | awk '{print $2}')