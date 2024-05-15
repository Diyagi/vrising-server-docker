#!/bin/bash
# shellcheck source=scripts/helper_functions.sh
source "$SCRIPTSDIR/helper_functions.sh"

gameconfig_file="$STEAMAPPDATA/Settings/ServerGameSettings.json"
gameconfig_dir=$(dirname "$gameconfig_file")

mkdir -p "$gameconfig_dir" || exit

# If file exists then check if it is writable
if [ -f "$gameconfig_file" ]; then
    if ! isWritable "$gameconfig_file"; then
        LogError "Unable to create $gameconfig_file"
        exit 1
    fi
# If file does not exist then check if the directory is writable
elif ! isWritable "$gameconfig_dir"; then
    # Exiting since the file does not exist and the directory is not writable.
    LogError "Unable to create $gameconfig_file"
    exit 1
fi

LogAction "Compiling ServerGameSettings.json"

export GAME_DIFFICULTY=${GAME_DIFFICULTY:-"Normal"}
export GAMEMODE_TYPE=${GAMEMODE_TYPE:-"PvP"}
export CLAN_SIZE=${CLAN_SIZE:-4}

jq '.GameDifficulty = env.GAME_DIFFICULTY |
    .GameModeType = env.GAMEMODE_TYPE |
    .ClanSize = (env.CLAN_SIZE | tonumber)' \
  < "${STEAMAPPSERVER}/VRisingServer_Data/StreamingAssets/Settings/ServerGameSettings.json" \
  > "${gameconfig_file}"

ExitCode=$?

# Normally jq exits with 2 if there was any usage problem or system error, 
# 3 if there was a jq program compile error, or 0 if the jq program ran.
if [ $ExitCode -eq 0 ]; then
    LogSuccess "Compiling ServerGameSettings.json done!"
fi

exit $ExitCode

