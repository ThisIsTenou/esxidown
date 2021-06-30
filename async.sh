#!/bin/sh

###############
## VARIABLES ##
###############
# Enter the absolute path to the directory in which esxidown.sh resides, without the trailing slash. Defaults to the folder of async.sh.
SCRIPTPATH=""
# Enter the absolute path to the directory in which esxidown.log should reside, without the trailing slash. Defaults to the folder of async.sh.
LOGPATH=""
# Can be used for testing, when set to 1 no actual shutdown commands are being issued.
TEST=0
# Number of times to wait for a VM to shutdown cleanly before forcing power off. (Default is 10, minimum is 1)
WAITTRYS=10
# How long to wait in seconds each try for a VM to shutdown. (Default is 15, minimum is 5)
WAITTIME=15

###################################
## Do not change anything below! ##
###################################
# Get current location of this script
SCRIPTLOC=$(dirname "$(readlink -f "$0")")
# Set defaults, if variables are empty or invalid
SCRIPTPATH=${SCRIPTPATH:-$SCRIPTLOC}
if [ ! -x "$SCRIPTPATH/esxidown.sh" ]; then
    echo "Path to script is invalid or script is not executable. Exiting."
    exit 1
fi
LOGPATH=${LOGPATH:-$SCRIPTLOC}
if [ ! -d "$LOGPATH" ]; then
    echo "Path to logfile is invalid, defaulting to directory of this script"
    LOGPATH=$SCRIPTLOC
fi
TEST=${TEST:-0}
if [ ! "$TEST" -eq 0 ] && [ ! "$TEST" -eq 1 ] 2>/dev/null; then
  echo "Couldn't determine if this is a test, assuming no."
  TEST=0
fi
WAITTRYS=${WAITTRYS:-10}
if [ ! "$WAITTRYS" -ge 1 ] 2>/dev/null; then
  WAITTRYS=10
fi
WAITTIME=${WAITTIME:-15}
if [ ! "$WAITTIME" -ge 5 ] 2>/dev/null; then
  WAITTIME=10
fi

# Executes esxidown.sh and passes all variables to it
nohup /bin/sh "$SCRIPTPATH/esxidown.sh" "$LOGPATH" $TEST $WAITTRYS $WAITTIME > /dev/null 2>&1 &
