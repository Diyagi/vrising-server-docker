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
if [ "$AVXSupport" == 0 ]; then
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

LogAction "Starting Server"

LogInfo "Starting Xvfb"
Xvfb :0 -screen 0 1024x768x16 &

LogInfo "Launching wine64 V Rising"
DISPLAY=:0.0 /usr/lib/wine/wine64 "${STEAMAPPSERVER}"/VRisingServer.exe -persistentDataPath "${STEAMAPPDATA}" > >(WineStdout) 2> >(WindeStderr) &
