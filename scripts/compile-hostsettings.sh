#!/bin/bash
# shellcheck source=scripts/helper_functions.sh
source "$SCRIPTSDIR/helper_functions.sh"

hostconfig_file="$STEAMAPPDATA/Settings/ServerHostSettings.json"
hostconfig_dir=$(dirname "$hostconfig_file")

mkdir -p "$hostconfig_dir" || exit

# If file exists then check if it is writable
if [ -f "$hostconfig_file" ]; then
    if ! isWritable "$hostconfig_file"; then
        LogError "Unable to create $hostconfig_file"
        exit 1
    fi
# If file does not exist then check if the directory is writable
elif ! isWritable "$hostconfig_dir"; then
    # Exiting since the file does not exist and the directory is not writable.
    LogError "Unable to create $hostconfig_file"
    exit 1
else
    LogInfo "Created ServerHostSettings.json"
    cp "${STEAMAPPSERVER}/VRisingServer_Data/StreamingAssets/Settings/ServerHostSettings.json" "$hostconfig_dir"
fi

LogAction "Compiling ServerHostSettings.json"

# If anything goes wrong, we bail
set -e

# ModifyJsonKey key value jsonarg jsonfile
ModifyJsonKey "AIUpdatesPerFrame" "${AI_UPDATES_PER_FRAME}" true "$hostconfig_file"
ModifyJsonKey "GiveStarterItems" "${GIVE_STARTER_ITEMS}" true "$hostconfig_file"
ModifyJsonKey "LogAllNetworkEvents" "${LOG_ALL_NETWORK_EVENTS}" true "$hostconfig_file"
ModifyJsonKey "LogAdminEvents" "${LOG_ADMIN_EVENTS}" true "$hostconfig_file"
ModifyJsonKey "LogDebugEvents" "${LOG_DEBUG_EVENTS}" true "$hostconfig_file"
ModifyJsonKey "EnableDangerousDebugEvents" "${ENABLE_DANGEROUS_DEBUG_EVENTS}" true "$hostconfig_file"
ModifyJsonKey "TrackArchetypeCreationsOnStartup" "${TRACK_ARCHETYPE_CREATIONS_ON_STARTUP}" true "$hostconfig_file"
ModifyJsonKey "ServerStartTimeOffset" "${SERVER_START_TIME_OFFSET}" true "$hostconfig_file"
ModifyJsonKey "PersistenceVersionOverride" "${PERSISTENCE_VERSION_OVERRIDE}" true "$hostconfig_file"
ModifyJsonKey "UseTeleportPlayersOutOfCollisionFix" "${USE_TELEPORT_PLAYERS_OUT_OF_COLLISION_FIX}" true "$hostconfig_file"
ModifyJsonKey "EnableBacktraceANR" "${ENABLE_BACKTRACE_ANR}" true "$hostconfig_file"
ModifyJsonKey "AnalyticsEnabled" "${ANALYTICS_ENABLED}" true "$hostconfig_file"
ModifyJsonKey "AnalyticsEnvironment" "${ANALYTICS_ENVIRONMENT}" false "$hostconfig_file"
ModifyJsonKey "AnalyticsDebug" "${ANALYTICS_DEBUG}" true "$hostconfig_file"
ModifyJsonKey "API.BindAddress" "${API_ADDRESS}" false "$hostconfig_file"
ModifyJsonKey "API.BasePath" "${API_BASE_PATH}" false "$hostconfig_file"
ModifyJsonKey "API.AccessList" "${API_ACCESS_LIST}" false "$hostconfig_file"

ExitCode=$?

# Normally jq exits with 2 if there was any usage problem or system error, 
# 3 if there was a jq program compile error, or 0 if the jq program ran.
if [ $ExitCode -eq 0 ]; then
    LogSuccess "Compiling ServerHostSettings.json done!"
fi

exit $ExitCode
