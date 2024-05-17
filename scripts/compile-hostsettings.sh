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
fi

LogAction "Compiling ServerHostSettings.json"

export FALLBACK_PORT=${FALLBACK_PORT:-9878}
export MIN_FREE_SLOTS_FOR_NEW_USERS=${MIN_FREE_SLOTS_FOR_NEW_USERS:-0}
export AI_UPDATES_PER_FRAME=${AI_UPDATES_PER_FRAME:-200}
export SERVER_BRANCH=${SERVER_BRANCH:-""}
export COMPRESS_SAVE_FILES=${COMPRESS_SAVE_FILES:-true}
export RUN_PERSISTENCE_TESTS_ON_SAVE=${RUN_PERSISTENCE_TESTS_ON_SAVE:-false}
export DUMP_PERSISTENCE_SUMMARY_ON_SAVE=${DUMP_PERSISTENCE_SUMMARY_ON_SAVE:-false}
export STORE_PERSISTENCE_DEBUG_DATA=${STORE_PERSISTENCE_DEBUG_DATA:-false}
export GIVE_STARTER_ITEMS=${GIVE_STARTER_ITEMS:-false}
export LOG_ALL_NETWORK_EVENTS=${LOG_ALL_NETWORK_EVENTS:-false}
export LOG_ADMIN_EVENTS=${LOG_ADMIN_EVENTS:-true}
export LOG_DEBUG_EVENTS=${LOG_DEBUG_EVENTS:-true}
export ADMIN_ONLY_DEBUG_EVENTS=${ADMIN_ONLY_DEBUG_EVENTS:-true}
export EVERYONE_IS_ADMIN=${EVERYONE_IS_ADMIN:-false}
export DISABLE_DEBUG_EVENTS=${DISABLE_DEBUG_EVENTS:-false}
export ENABLE_DANGEROUS_DEBUG_EVENTS=${ENABLE_DANGEROUS_DEBUG_EVENTS:-false}
export TRACK_ARCHETYPE_CREATIONS_ON_STARTUP=${TRACK_ARCHETYPE_CREATIONS_ON_STARTUP:-false}
export SERVER_START_TIME_OFFSET=${SERVER_START_TIME_OFFSET:-0.0}
export PERSISTENCE_VERSION_OVERRIDE=${PERSISTENCE_VERSION_OVERRIDE:--1}
export USE_TELEPORT_PLAYERS_OUT_OF_COLLISION_FIX=${USE_TELEPORT_PLAYERS_OUT_OF_COLLISION_FIX:-true}
export REMOTE_BANS_URL=${REMOTE_BANS_URL:-""}
export REMOTE_ADMINS_URL=${REMOTE_ADMINS_URL:-""}
export AFK_KICK_TYPE=${AFK_KICK_TYPE:-0}
export AFK_KICK_DURATION=${AFK_KICK_DURATION:-1}
export AFK_KICK_WARNING_DURATION=${AFK_KICK_WARNING_DURATION:-14}
export AFK_KICK_PLAYER_RATIO=${AFK_KICK_PLAYER_RATIO:-0.5}
export ENABLE_BACKTRACE_ANR=${ENABLE_BACKTRACE_ANR:-false}
export ANALYTICS_ENABLED=${ANALYTICS_ENABLED:-true}
export ANALYTICS_ENVIRONMENT=${ANALYTICS_ENVIRONMENT:-"prod"}
export ANALYTICS_DEBUG=${ANALYTICS_DEBUG:-false}
export USE_DOUBLE_TRANSPORT_LAYER=${USE_DOUBLE_TRANSPORT_LAYER:-true}
export PRIVATE_GAME=${PRIVATE_GAME:-false}
export API_ENABLED=${API_ENABLED:-false}
export API_ADDRESS=${API_ADDRESS:-"*"}
export API_PORT=${API_PORT:-9090}
export API_BASE_PATH=${API_BASE_PATH:-"/"}
export API_ACCESS_LIST=${API_ACCESS_LIST:-""}
export API_PROMETHEUS_DELAY=${API_PROMETHEUS_DELAY:-30}
export RCON_TIMEOUT_SECONDS=${RCON_TIMEOUT_SECONDS:-300}
export RCON_MAX_PASSWORD_TRIES=${RCON_MAX_PASSWORD_TRIES:-99}
export RCON_BAN_MINUTES=${RCON_BAN_MINUTES:-0}
export RCON_SEND_AUTH_IMMEDIATELY=${RCON_SEND_AUTH_IMMEDIATELY:-true}
export RCON_MAX_CONNECTIONS_PER_IP=${RCON_MAX_CONNECTIONS_PER_IP:-20}
export RCON_MAX_CONNECTIONS=${RCON_MAX_CONNECTIONS:-20}
export RCON_EXPERIMENTAL_COMMANDS_ENABLED=${RCON_EXPERIMENTAL_COMMANDS_ENABLED:-false}

jq '.FallbackPort = (env.FALLBACK_PORT | tonumber) |
    .MinFreeSlotsNeededForNewUsers = (env.MIN_FREE_SLOTS_FOR_NEW_USERS | tonumber) |
    .AIUpdatesPerFrame = (env.AI_UPDATES_PER_FRAME | tonumber) |
    .ServerBranch = env.SERVER_BRANCH |
    .CompressSaveFiles = (env.COMPRESS_SAVE_FILES | test("true")) |
    .RunPersistenceTestsOnSave = (env.RUN_PERSISTENCE_TESTS_ON_SAVE | test("true")) |
    .DumpPersistenceSummaryOnSave = (env.DUMP_PERSISTENCE_SUMMARY_ON_SAVE | test("true")) |
    .StorePersistenceDebugData = (env.STORE_PERSISTENCE_DEBUG_DATA | test("true")) |
    .GiveStarterItems = (env.GIVE_STARTER_ITEMS | test("true")) |
    .LogAllNetworkEvents = (env.LOG_ALL_NETWORK_EVENTS | test("true")) |
    .LogAdminEvents = (env.LOG_ADMIN_EVENTS | test("true")) |
    .LogDebugEvents = (env.LOG_DEBUG_EVENTS | test("true")) |
    .AdminOnlyDebugEvents = (env.ADMIN_ONLY_DEBUG_EVENTS | test("true")) |
    .EveryoneIsAdmin = (env.EVERYONE_IS_ADMIN | test("true")) |
    .DisableDebugEvents = (env.DISABLE_DEBUG_EVENTS | test("true")) |
    .EnableDangerousDebugEvents = (env.ENABLE_DANGEROUS_DEBUG_EVENTS | test("true")) |
    .TrackArchetypeCreationsOnStartup = (env.TRACK_ARCHETYPE_CREATIONS_ON_STARTUP | test("true")) |
    .ServerStartTimeOffset = (env.SERVER_START_TIME_OFFSET | tonumber) |
    .PersistenceVersionOverride = (env.PERSISTENCE_VERSION_OVERRIDE | tonumber) |
    .UseTeleportPlayersOutOfCollisionFix = (env.USE_TELEPORT_PLAYERS_OUT_OF_COLLISION_FIX | test("true")) |
    .RemoteBansURL = env.REMOTE_BANS_URL |
    .RemoteAdminsURL = env.REMOTE_ADMINS_URL |
    .AFKKickType = (env.AFK_KICK_TYPE | tonumber) |
    .AFKKickDuration = (env.AFK_KICK_DURATION | tonumber) |
    .AFKKickWarningDuration = (env.AFK_KICK_WARNING_DURATION | tonumber) |
    .AFKKickPlayerRatio = (env.AFK_KICK_PLAYER_RATIO | tonumber) |
    .EnableBacktraceANR = (env.ENABLE_BACKTRACE_ANR | test("true")) |
    .AnalyticsEnabled = env.ANALYTICS_ENABLED |
    .AnalyticsEnvironment = env.ANALYTICS_ENVIRONMENT |
    .AnalyticsDebug = env.ANALYTICS_DEBUG |
    .UseDoubleTransportLayer = (env.USE_DOUBLE_TRANSPORT_LAYER | test("true")) |
    .PrivateGame = (env.PRIVATE_GAME | test("true")) |
    .API.Enabled = (env.API_ENABLED | test("true")) |
    .API.BindAddress = env.API_ADDRESS |
    .API.BindPort = (env.API_PORT | tonumber) |
    .API.BasePath = env.API_BASE_PATH |
    .API.AccessList = env.API_ACCESS_LIST |
    .API.PrometheusDelay = (env.API_PROMETHEUS_DELAY | tonumber) |
    .Rcon.TimeoutSeconds = (env.RCON_TIMEOUT_SECONDS | tonumber) |
    .Rcon.MaxPasswordTries = (env.RCON_MAX_PASSWORD_TRIES | tonumber) |
    .Rcon.BanMinutes = (env.RCON_BAN_MINUTES | tonumber) |
    .Rcon.SendAuthImmediately = (env.RCON_SEND_AUTH_IMMEDIATELY | test("true")) |
    .Rcon.MaxConnectionsPerIp = (env.RCON_MAX_CONNECTIONS_PER_IP | tonumber) |
    .Rcon.MaxConnections = (env.RCON_MAX_CONNECTIONS | tonumber) |
    .Rcon.ExperimentalCommandsEnabled = (env.RCON_EXPERIMENTAL_COMMANDS_ENABLED | test("true"))' \
  < "${STEAMAPPSERVER}/VRisingServer_Data/StreamingAssets/Settings/ServerHostSettings.json" \
  > "${hostconfig_file}"

ExitCode=$?

# Normally jq exits with 2 if there was any usage problem or system error, 
# 3 if there was a jq program compile error, or 0 if the jq program ran.
if [ $ExitCode -eq 0 ]; then
    LogSuccess "Compiling ServerHostSettings.json done!"
fi

exit $ExitCode
