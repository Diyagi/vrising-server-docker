#!/bin/bash

IsInstalled() {
  if  [ -e "${STEAMAPPSERVER}/VRisingServer.exe" ] && [ -e "${STEAMAPPSERVER}/steamapps/appmanifest_1829350.acf" ]; then
    return 0
  fi
  return 1
}

IsAVXSupported() {
    if ! grep -q -o 'avx[^ ]*' /proc/cpuinfo; then
	    return 0
    fi 
    return 1
}

UpdateRequired() {
  LogAction "Checking for new V Rising Server updates"

  #define local variables
  local CURRENT_MANIFEST LATEST_MANIFEST temp_file http_code updateAvailable

  #check steam for latest version
  temp_file=$(mktemp)
  http_code=$(curl https://api.steamcmd.net/v1/info/1829350 --output "$temp_file" --silent --location --write-out "%{http_code}")

  if [ "$http_code" -ne 200 ]; then
      LogError "There was a problem reaching the Steam api. Unable to check for updates!"
      rm "$temp_file"
      return 2
  fi

  # Parse temp file for manifest id
  LATEST_MANIFEST=$(grep -Po '"1829351".*"gid": "\d+"' <"$temp_file" | sed -r 's/.*("[0-9]+")$/\1/' | tr -d '"')
  rm "$temp_file"

  if [ -z "$LATEST_MANIFEST" ]; then
      LogError "The server response does not contain the expected BuildID. Unable to check for updates!"
      return 2
  fi

  # Parse current manifest from steam files
  CURRENT_MANIFEST=$(awk '/manifest/{count++} count==2 {print $2; exit}' "${STEAMAPPSERVER}/steamapps/appmanifest_1829350.acf" | tr -d '"')
  LogInfo "Current Version: $CURRENT_MANIFEST"

  # Log any updates available
  local updateAvailable=false
  if [ "$CURRENT_MANIFEST" != "$LATEST_MANIFEST" ]; then
    LogInfo "An Update Is Available. Latest Version: $LATEST_MANIFEST."
    updateAvailable=true
  fi

  # Warn if version is locked
  if [ "$updateAvailable" == false ]; then
    LogSuccess "The server is up to date!"
    return 1
  fi
}

InstallServer() {
    /home/steam/steamcmd/steamcmd.sh +@sSteamCmdForcePlatformType windows +@sSteamCmdForcePlatformBitness 64 +force_install_dir "${STEAMAPPSERVER}" +login anonymous +app_update 1829350 validate +quit
}
