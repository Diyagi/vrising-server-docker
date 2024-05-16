#!/bin/bash
# shellcheck source=scripts/helper_functions.sh
source "${SCRIPTSDIR}/helper_functions.sh"

if [ ! -d "$LOGSDIR" ]; then mkdir "$LOGSDIR"; fi

# Rename latest.log to VRising-{LastModifiedDate}.log
# if the file exists and its not empty
ContainerLog="$LOGSDIR/latest.log"
if [ -f "$ContainerLog" ] && [ -s "$ContainerLog" ]; then
	LogDate=$(date --date="@$(stat -c "%Y" "$ContainerLog")" +'%Y%m%d-%H%M%S')
    mv "$ContainerLog" "$LOGSDIR/VRising-$LogDate.log"
fi

# Checks for root, updates UID and GID of user steam
# and updates folders owners
if [[ "$(id -u)" -eq 0 ]] && [[ "$(id -g)" -eq 0 ]]; then
    if [[ "${PUID}" -ne 0 ]] && [[ "${PGID}" -ne 0 ]]; then
        LogAction "EXECUTING USERMOD"
        usermod -o -u "${PUID}" steam
        groupmod -o -g "${PGID}" steam
        chown -R steam:steam "${STEAMAPPDIR}"
    else
        LogError "Running as root is not supported, please fix your PUID and PGID!"
        exit 1
    fi
elif [[ "$(id -u)" -eq 0 ]] || [[ "$(id -g)" -eq 0 ]]; then
   LogError "Running as root is not supported, please fix your user!"
   exit 1
fi

if ! [ -w "${STEAMAPPSERVER}" ]; then
    LogError "${STEAMAPPSERVER}r is not writable."
    exit 1
fi

if ! [ -w "${STEAMAPPDATA}" ]; then
    LogError "${STEAMAPPDATA} is not writable."
    exit 1
fi

# Trap SIGTERM so we can gracefully shutdown the gameserver
# Need su steam bc the wine commands has to run with the same prefix
# as the gameserver, tried to use root and just change the 
# WINEPREFIX but it complains abt not being owner.
trap 'su steam -c "$SCRIPTSDIR/shutdown_gameserver.sh"' SIGTERM

#Restart cleanup
if [ -f "/tmp/.X0-lock" ]; then rm /tmp/.X0-lock; fi

if [[ "$(id -u)" -eq 0 ]]; then
    su steam -c "$SCRIPTSDIR/start.sh" 2>&1 | tee >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' > "$ContainerLog") >&2 &
else
    "$SCRIPTSDIR/start.sh" 2>&1 | tee >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' > "$ContainerLog") >&2 &
fi

# Process ID of su
killpid="$!"
wait "$killpid"
