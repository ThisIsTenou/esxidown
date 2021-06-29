#!/bin/sh
# Runs a shell command asynchronously.

nohup /bin/sh /vmfs/volumes/$(hostname | cut -d '.' -f1)_datastore-local-1/000-scripts/esxidown.sh > /dev/null 2>&1 &
