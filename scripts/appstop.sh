#!/bin/bash
scripts/stop_server.sh > >(logger -p user.info) 2> >(logger -p user.warn)