

# VRising Server Docker

[![Release](https://img.shields.io/github/v/release/Diyagi/vrising-server-docker)](https://github.com/Diyagi/vrising-server-docker/releases)
[![Docker Pulls](https://img.shields.io/docker/pulls/diyagi/vrising-server-docker)](https://hub.docker.com/r/diyagi/vrising-server-docker)
[![Image Size](https://img.shields.io/docker/image-size/diyagi/vrising-server-docker/latest)](https://hub.docker.com/r/diyagi/vrising-server-docker/tags)
[![Docker Hub](https://img.shields.io/badge/Docker_Hub-VRising-blue?logo=docker)](https://hub.docker.com/r/diyagi/vrising-server-docker)

>[!NOTE]
> This image features ✨**gracefully server shutdown**✨, meaning you should not experience rollbacks after an shutdown/restart.
<br>
A Docker container for hosting your own dedicated server using Ubuntu 24.04 and WineHQ 9.
<br>

## Acknowledgements
 - Base image from [CM2Walki/steamcmd](https://github.com/CM2Walki/steamcmd)

 - Code from [palworld-server-docker](https://github.com/thijsvanloef/palworld-server-docker)

## Getting Started

Follow this [docker-compose-yml](/docker-compose.yml) example and check [environment variables](#container-environment-variables) below for more information.

```yaml
services:
  vrising:
    image: diyagi/vrising-server-docker:latest
    restart: unless-stopped # Required for the restarts to work
    stop_grace_period: 15s # Might need to increase with longer saves
    ports:
      - 9876:9876/udp
      - 9877:9877/udp
    environment:
      TZ: "America/Los_Angeles"
      PUID: 1001
      PGID: 1001
      VR_NAME: "V Rising Docker Server"
      VR_DESCRIPTION: "V Rising server hosted on Docker"
      VR_RCON_ENABLED: true
      VR_RCON_PASSWORD: "rconPassword"
      VR_RCON_PORT: 25575
      VR_GAME_PORT: 9876
      VR_QUERY_PORT: 9877
      VR_LIST_ON_EOS: true
      VR_LIST_ON_STEAM: true
      VR_SAVE_NAME: "dockerWorld"
    volumes:
    - ./awesome-vrising-server/server:/vrising/server
    - ./awesome-vrising-server/data:/vrising/data
    - ./awesome-vrising-server/announce:/vrising/announce # Only needed if you are using Auto Announce

```

>[!TIP]
> To manually change the `ServerGameSettings.json` and/or `ServerHostSettings.json` you need to set `COMPILE_GAME_SETTINGS` and/or `COMPILE_HOST_SETTINGS` to `false`.
>
> When setting `COMPILE_GAME_SETTINGS` or `COMPILE_HOST_SETTINGS` to `true` you are expected to use environment variables to configure the server without touching `ServerGameSettings.json` and/or `ServerHostSettings.json`

## Container Environment Variables

| Variable | Type/Default | Description |
| :------- | -----------| :----------- |
| `PUID` | `1000` | UID used by the container to run the server as |
| `PGID` | `1000` | GID used by the container to run the server as |
| `TZ` | `Europe/Brussels` | Timezone, important if you are running Cron tasks. |
| `UPDATE_ON_BOOT` | `true` | Checks for updates on start and updates it if needed |
| `COMPILE_HOST_SETTINGS`| `false` | Disable the generation of `ServerHostSettings.json` using the env vars below. It does not affect the env vars starting with `VR_`, these env vars are used by the gameserver itself |
| `COMPILE_GAME_SETTINGS`| `false` | Disable the generation of `ServerGameSettings.json` using the env vars. |
| `AUTO_UPDATE_ENABLED` | `false` | Enable/Disables Auto Update.<br>If docker restart is not set to policy `always` or `unless-stopped` then the server will shutdown and will need to be manually restarted.<br>**Requires RCON** |
| `AUTO_UPDATE_CRON_EXPRESSION` | `0 * * * *` | Cron expression to when to run the update check. |
| `AUTO_UPDATE_WARN_MINUTES` | `30,15,10,5,3,2,1` | How many minutes until restart and announce intervals.<br>Example: `30,15,10,5,3,2,1` will shutdown the server in `30` minutes and announce the shut down at `30,15,10,5,3,2` and `1` minute mark. |
| `AUTO_UPDATE_WARN_MESSAGE` | `Server will restart in ~{t} min. Reason: Scheduled Update` | Message used to announce the restart.<br>`~{t}` will be replaced in the message by the remaining time until shutdown. |
| `AUTO_REBOOT_ENABLED` | `false` | Enable/Disable Auto Reboot.<br>If docker restart is not set to policy `always` or `unless-stopped` then the server will shutdown and will need to be manually restarted.<br>**Requires RCON** |
| `AUTO_REBOOT_CRON_EXPRESSION` | `0 0 * * *` | Cron expression to when to run the reboot. |
| `AUTO_REBOOT_WARN_MINUTES` | `15,10,5,3,2,1` | How many minutes until restart and announce intervals.<br>Example: `30,15,10,5,3,2,1` will shutdown the server in `30` minutes and announce the shut down at `30,15,10,5,3,2` and `1` minute mark. |
| `AUTO_REBOOT_WARN_MESSAGE` | `Server will restart in ~{t} min. Reason: Scheduled Restart` | Message used to announce the restart.<br>`~{t}` will be replaced in the message by the remaining time until shutdown |
| `AUTO_ANNOUNCE_ENABLED` | `false` | Enable/Disable Auto Announce of messages. |
| `AUTO_ANNOUNCE_CRON_EXPRESSION` | `*/10 * * * *` | Cron expression to when to announce messages.<br>Default is every 10 minutes.<br>**Requires RCON** |



## Host Settings Environment Variables (Game Server)

>[!IMPORTANT]
> `VR_` prefixed environment variables are used by the **game** server itself, not added by the container.
>
> Because these are read by the game server itself, setting `COMPILE_HOST_SETTINGS` to `false` won't affect how these environment variables work. [Official Doc](https://github.com/StunlockStudios/vrising-dedicated-server-instructions/blob/master/1.0.x/INSTRUCTIONS.md#server-host-settings).
>
> These environment variables will **override** their respective values in `ServerHostSettings.json`.

| Variable | Type/Default | Description |
| :------- | :------------|:------------|
| `VR_NAME` | `text` | Name of the server. The name that shows up in server list. |
| `VR_DESCRIPTION` | `text` | Short server description. Shows up in details panel of server list when entry is selected. Also printed in chat when connecting to server. |
| `VR_GAME_PORT` | `9876` | UDP port for game traffic. |
| `VR_QUERY_PORT` | `9877` | UDP port for Steam server list features. |
| `VR_ADDRESS` | `text` | Bind to a specific IP address. |
| `VR_HIDEIPADDRESS` | `false` | When listing server on EOS server list, the IP address will not be shown/advertised. Players will connect via relay servers. |
| `VR_MAX_USERS` | `40` | Max number of concurrent players on server. The maximum number technically supported is `128`. |
| `VR_MAX_ADMINS` | `4` | Max number of admins to allow connect even when server is full. |
| `VR_FPS` | `30` | Target FPS for server. |
| `VR_LOWER_FPS_WHEN_EMPTY` | `false` | Run the server at a lower framerate target when no players are logged in. |
| `VR_LOWER_FPS_WHEN_EMPTY_VALUE` | `1` | Set the framerate target for when `LowerFPSWhenEmpty` is active. |
| `VR_PASSWORD` | `text` | Set a password or leave empty. |
| `VR_SECURE` | `true` | Enable VAC protection on server. VAC banned clients will not be able to connect. |
| `VR_LIST_ON_EOS` | `false` | Register on EOS list server or not. The client looks for servers here by default, due to additional features available. |
| `VR_LIST_ON_STEAM` | `false` | Register on Steam list server or not. |
| `VR_PRESET` | `text` | Load a ServerGameSettings preset. |
| `VR_DIFFICULTY_PRESET` | `text` | Load a GameDifficulty preset. |
| `VR_SAVE_NAME` | `world1` | Name of save file/directory. Must be a valid directory name. |
| `VR_SAVE_COUNT` | `20` | Number of autosaves to keep. |
| `VR_SAVE_INTERVAL` | `120` | Interval in seconds between each auto save. |
| `VR_AUTOSAVESMARTKEEP` | `10:1:1` `30:0:1`<br>`60:0:1` `120:0:1`<br>`180:0:1` `240:0:1`<br>`360:0:1` `720:0:1` <br>`1440:0:1` `2880:0:1`<br>`43200:99:0` | . |
| `VR_LAN_MODE` | `false` | Enable LAN mode. |
| `VR_RESET_DAYS_INTERVAL` | `0` | Days between scheduled resets/wipes. When the server starts, and is about to load a save file, it checks if it is time to reset and start a new save file. The previous save file is backed up. Defaults to `0`, which means the feature is disabled. |
| `VR_DAY_OF_RESET` | `enum` | If you want the server to reset on Saturdays, every two weeks, but it is not Saturday when you initially set up you server then you can set `ResetDaysInterval` to `14` and then set this to `Saturday`. It will check that at least `ResetDaysInterval` days has passed and that it is the day of `DayOfReset`. If you do not want to restrict reset to a specific day, but just rely on the value of `ResetDaysInterval`, then set this to `Any`, which is also the default.<br>Possible values: `Any`, `Monday`, `Tuesday`, `Wednesday`, `Thursday`, `Friday`, `Saturday`, `Sunday` |
| `VR_RCON_ENABLED` | `false` | Enable or disable Rcon functionality. |
| `VR_RCON_PORT` | `25575` | Rcon TCP port. |
| `VR_RCON_PASSWORD` | `text` | Password to access RCON. |
| `VR_RCON_BIND_ADDRESS` | `text` | Binds RCON socket to specified address. Will override the "global" Address setting, if you want to bind to a separate internal interface for instance. |

# Host Settings Environment Variables 

>[!IMPORTANT]
> The environment variables below are added by the container, when using any of these they will **overwrite** what's in the `ServerHostSettings.json` file.
>
> When using these environment variables any configuration manually made to `ServerHostSettings.json` will be **overwritten**, meaning you should only use environment variables to configure `ServerHostSettings.json`.
>
> If you want to **manually** change the `ServerHostSettings.json` file set `COMPILE_HOST_SETTINGS` to `false`, this will disable all environment variables below.

| Variable | Type/Default | Description |
| :------- | :------------|:------------|
| `FALLBACK_PORT` | `9878` | Unknown |
| `MIN_FREE_SLOTS_FOR_NEW_USERS` | `0` | Unknown |
| `AI_UPDATES_PER_FRAME` | `200` | Unknown |
| `SERVER_BRANCH` | `text` | Unknown |
| `COMPRESS_SAVE_FILES` | `true` | Unknown |
| `RUN_PERSISTENCE_TESTS_ON_SAVE` | `false` | Unknown |
| `DUMP_PERSISTENCE_SUMMARY_ON_SAVE` | `false` | Unknown |
| `STORE_PERSISTENCE_DEBUG_DATA` | `false` | Unknown |
| `GIVE_STARTER_ITEMS` | `false` | Unknown |
| `LOG_ALL_NETWORK_EVENTS` | `false` | Unknown |
| `LOG_ADMIN_EVENTS` | `true` | Unknown |
| `LOG_DEBUG_EVENTS` | `true` | Unknown |
| `ADMIN_ONLY_DEBUG_EVENTS` | `true` | Unknown |
| `EVERYONE_IS_ADMIN` | `false` | Unknown |
| `DISABLE_DEBUG_EVENTS` | `false` | Unknown |
| `ENABLE_DANGEROUS_DEBUG_EVENTS` | `false` | Unknown |
| `TRACK_ARCHETYPE_CREATIONS_ON_STARTUP` | `false` | Unknown |
| `SERVER_START_TIME_OFFSET` | `0.0` | Unknown |
| `PERSISTENCE_VERSION_OVERRIDE` | `-1` | Unknown |
| `USE_TELEPORT_PLAYERS_OUT_OF_COLLISION_FIX` | `true` | Unknown |
| `REMOTE_BANS_URL` | `text` | Unknown |
| `REMOTE_ADMINS_URL` | `text` | Unknown |
| `AFK_KICK_TYPE` | `0` | Unknown |
| `AFK_KICK_DURATION` | `1 `| Unknown |
| `AFK_KICK_WARNING_DURATION` | `14` | Unknown |
| `AFK_KICK_PLAYER_RATIO` | `0.5` | Unknown |
| `ENABLE_BACKTRACE_ANR` | `false` | Unknown |
| `ANALYTICS_ENABLED` | `true` | Unknown |
| `ANALYTICS_ENVIRONMENT` | `"prod"` | Unknown |
| `ANALYTICS_DEBUG` | `false` | Unknown |
| `USE_DOUBLE_TRANSPORT_LAYER` | `true` | Unknown |
| `PRIVATE_GAME` | `false` | Unknown |
| `API_ENABLED` | `false` | Unknown |
| `API_ADDRESS` | `"*"` | Unknown |
| `API_PORT` | `9090` | Unknown |
| `API_BASE_PATH` | `"/"` | Unknown |
| `API_ACCESS_LIST` | `text` | Unknown |
| `API_PROMETHEUS_DELAY` | `30` | Unknown |
| `RCON_TIMEOUT_SECONDS` | `300` | Unknown |
| `RCON_MAX_PASSWORD_TRIES` | `99` | Unknown |
| `RCON_BAN_MINUTES` | `0` | Unknown |
| `RCON_SEND_AUTH_IMMEDIATELY` | `true` | Unknown |
| `RCON_MAX_CONNECTIONS_PER_IP` | `20` | Unknown |
| `RCON_MAX_CONNECTIONS` | `20` | Unknown |
| `RCON_EXPERIMENTAL_COMMANDS_ENABLED` | `true` | Unknown |

# Game Settings Environment Variables

>[!IMPORTANT]
> The environment variables below are added by the container, when using any of these they will **overwrite** what's in the `ServerGameSettings.json` file.
>
> When using these environment variables any configuration manually made to `ServerGameSettings.json` will be **overwritten**, meaning you should only use environment variables to configure `ServerGameSettings.json`.
>
> If you want to **manually** change the `ServerGameSettings.json` file set `COMPILE_GAME_SETTINGS` to `false`, this will disable all environment variables below.


>[!NOTE]
> Not everything in `ServerGameSettings.json` can be configured using environment variables.
>
> If you need anything that's not covered feel free to open an Issue or PR.


| Variable | Type/Default | Description |
| :------- | :------------|:------------|
| `GAME_DIFFICULTY` | `Normal` | Changes the game difficulty. |
| `GAMEMODE_TYPE` | `PvP` | Changes between `PvP` and `PvE`. |
| `CLAN_SIZE` | `4` | Max amount players that can join the same Clan. |

## RCON Commands

>[!WARNING]
> RCON will only work if it's properly configured, either by setting it's environment variables (`VR_RCON_ENABLED`, `VR_RCON_PORT` and `VR_RCON_PASSWORD`) or by manually configuring it in the `ServerHostSettings.json` file.

To use RCON you can use docker exec:
```bash
docker exec -it container-name rcon-cli "<command> <value>"
```

If you need external RCON access, remember to expose it's port in the container.

| Command | Parameters | Description |
|---------|:-----------|:------------|
| `help` | [command] | List all commands, or additional information about a specific command. |
| `announce` | &lt;message&gt; | Sends a message to all players connected to the server. |
| `announcerestart` | &lt;number&gt; | Sends a pre-configured message that announces server restart in x minutes to all players connected to the server. Less flexible than announce but has the benefit of being localized to each users language. |
| `shutdown` | &lt;message times&gt; &lt;message&gt; | Schedule shutdown of the server. |
| `cancelshutdown` | [message] | Cancel an active shutdown, with optional message. |
| `name` | &lt;name&gt; | Set/change the server name during runtime. |
| `description` | &lt;description&gt; | Set/change the server description during runtime. |
| `password` | [password] \| --clear | Set/change/clear the server password during runtime. |
| `version` | - | Show server version. |
| `time` | - | Show server time. |

## Auto Announce

>[!IMPORTANT]
>This requires RCON to be enabled !

Auto Announce works by reading text files with the extension `.announce`, each file is one message and the Auto Announce will rotate through each file in a loop.
<br>The folder containing the `.announce` files must be mounted inside the container to the path `/vrising/announce`.
<br>The time between each message can be configured using cron expression with the environment variable `AUTO_ANNOUNCE_CRON_EXPRESSION`.

It is recommended to follow this pattern to name the `.announce` files:
<br>`00-something.announce` `01-something.announce`
<br>The first 2 numbers will dictate the order of the message, meaning `00` will be the first message to be displayed and after the amount of time set with `AUTO_ANNOUNCE_CRON_EXPRESSION` the message `01` will be displayed.
<br>You can replace `something` in the file name with anything that helps you identify the message inside it.

>[!IMPORTANT]
>Announces are limited to 510 characters, this is a limit imposed by the game.

After mounting the `announce` folder with the messages, you can test each message by running the following command with the message number as the parameter (like `00` or `01`) while the server is running:
```bash
docker exec -it container-name testannounce <message number>
```

Messages can be modified while the server is running, but the cron expression (`AUTO_ANNOUNCE_CRON_EXPRESSION`) requires a restart to apply.
<br>More info about message formatting for the announcements (like colors!) [here](https://github.com/Diyagi/vrising-server-docker/wiki/Formatting-announce-messages).
