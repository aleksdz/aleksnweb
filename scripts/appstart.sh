#!/bin/bash
scripts/start_server.sh > >(logger -p user.info) 2> >(logger -p user.warn)