#!/bin/bash
# shellcheck source=scripts/helper_functions.sh
source "${SCRIPTSDIR}/helper_functions.sh"

# shellcheck source=scripts/helper_functions.sh
source "${SCRIPTSDIR}/helper_install.sh"

dirExists "${STEAMAPPSERVER}" || exit
isWritable "${STEAMAPPSERVER}" || exit
isExecutable "${STEAMAPPSERVER}" || exit

cd "${STEAMAPPSERVER}" || exit

IsAVXSupported
AVXSupport=$?
if [ "$AVXSupport" == 1 ]; then
    LogError "AVX is required but not supported on this hardware."
    exit
fi

IsInstalled
ServerInstalled=$?
if [ "$ServerInstalled" == 1 ]; then
    LogInfo "Server installation not detected."
    LogAction "Starting Installation"
    InstallServer
fi

# Update Only If Already Installed
if [ "$ServerInstalled" == 0 ] && [ "${UPDATE_ON_BOOT,,}" == true ]; then
    UpdateRequired
    IsUpdateRequired=$?
    if [ "$IsUpdateRequired" == 0 ]; then
        LogAction "Starting Update"
        InstallServer
    fi
fi

if [ "${COMPILE_HOST_SETTINGS,,}" = false ]; then
  LogAction "GENERATING HOST SETTINGS"
  LogWarn "Host Settings env vars will not be applied due to COMPILE_HOST_SETTINGS being set to FALSE!"

else
  LogAction "GENERATING HOST SETTINGS"
  LogInfo "Using Env vars to create ServerHostSettings.json"
  "${SCRIPTSDIR}"/compile-hostsettings.sh || exit
fi

if [ "${COMPILE_GAME_SETTINGS,,}" = false ]; then
  LogAction "GENERATING GAME SETTINGS"
  LogWarn "Game Settings env vars will not be applied due to COMPILE_GAME_SETTINGS being set to FALSE!"

else
  LogAction "GENERATING GAME SETTINGS"
  LogInfo "Using Env vars to create ServerGameSettings.json"
  "${SCRIPTSDIR}"/compile-gamesettings.sh || exit
fi

ParseRCONAccess
export RCON_ENABLED=$?
if [ "$RCON_ENABLED" == 1 ]; then
  LogWarn "Failed to parse RCON info or RCON is disabled"
  LogWarn "Features that uses RCON will be disabled!"
fi

LogAction "GENERATING CRONTAB"
truncate -s 0  "${SCRIPTSDIR}/crontab"

if [ "${AUTO_UPDATE_ENABLED,,}" = true ] && [ "${UPDATE_ON_BOOT}" = true ]; then
    LogInfo "AUTO_UPDATE_ENABLED=${AUTO_UPDATE_ENABLED,,}"
    LogInfo "Adding cronjob for auto updating"
    echo "$AUTO_UPDATE_CRON_EXPRESSION bash ${SCRIPTSDIR}/update.sh" >> "${SCRIPTSDIR}/crontab"
    supercronic -quiet -test "${SCRIPTSDIR}/crontab" || exit
fi

if [ "${AUTO_REBOOT_ENABLED,,}" = true ]; then
    LogInfo "AUTO_REBOOT_ENABLED=${AUTO_REBOOT_ENABLED,,}"
    LogInfo "Adding cronjob for auto rebooting"
    echo "$AUTO_REBOOT_CRON_EXPRESSION bash ${SCRIPTSDIR}/auto_reboot.sh" >> "${SCRIPTSDIR}/crontab"
    supercronic -quiet -test "${SCRIPTSDIR}/crontab" || exit
fi

if [ -s "${SCRIPTSDIR}/crontab" ]; then
    supercronic -passthrough-logs "${SCRIPTSDIR}/crontab" &
    LogInfo "Cronjobs started"
else
    LogInfo "No Cronjobs found"
fi


LogAction "Starting Server"

LogInfo "Starting Xvfb"
Xvfb :0 -screen 0 1024x768x16 &

LogInfo "Launching wine64 V Rising"
DISPLAY=:0.0 wine64 "${STEAMAPPSERVER}"/VRisingServer.exe -persistentDataPath "${STEAMAPPDATA}" > >(WineStdout) 2> >(WindeStderr)
