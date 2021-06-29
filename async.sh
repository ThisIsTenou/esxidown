#!/bin/sh
# Runs a shell command asynchronously.

nohup /bin/sh /vmfs/volumes/yourdatastore/esxidown.sh > /dev/null 2>&1 &
