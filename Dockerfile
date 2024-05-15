FROM diyagi/steamcmd-wine:root-noble as base-steamcmd-wine

LABEL maintainer="github@diyagi.dev" \
      name="diyagi/vrising-server-docker" \
      github="https://github.com/Diyagi/vrising-server-docker" \
      dockerhub="https://hub.docker.com/r/diyagi/vrising-server-docker/" \
      org.opencontainers.image.authors="Diyagi" \
      org.opencontainers.image.source="https://github.com/Diyagi/vrising-server-docker"

ARG DEBIAN_FRONTEND="noninteractive"
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends --no-install-suggests \
    tzdata \
    jq=1.7.1-3build1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV STEAMAPP vrising
ENV STEAMAPPDIR "/${STEAMAPP}"
ENV STEAMAPPSERVER "${STEAMAPPDIR}/server"
ENV STEAMAPPDATA "${STEAMAPPDIR}/data"
ENV LOGSDIR "${STEAMAPPDATA}/logs"
ENV SCRIPTSDIR "${STEAMAPPDIR}/scripts"

ENV PUID=1000 \
    PGID=1000 \
    COMPILE_HOST_SETTINGS=true \
    COMPILE_GAME_SETTINGS=false \
    UPDATE_ON_BOOT=true \
    FALLBACK_PORT=9878 \
    MIN_FREE_SLOTS_FOR_NEW_USERS=0 \
    AI_UPDATES_PER_FRAME=200 \
    SERVER_BRANCH="" \
    COMPRESS_SAVE_FILES=true \
    RUN_PERSISTENCE_TESTS_ON_SAVE=false \
    DUMP_PERSISTENCE_SUMMARY_ON_SAVE=false \
    STORE_PERSISTENCE_DEBUG_DATA=false \
    GIVE_STARTER_ITEMS=false \
    LOG_ALL_NETWORK_EVENTS=false \
    LOG_ADMIN_EVENTS=true \
    LOG_DEBUG_EVENTS=true \
    ADMIN_ONLY_DEBUG_EVENTS=true \
    EVERYONE_IS_ADMIN=false \
    DISABLE_DEBUG_EVENTS=false \
    ENABLE_DANGEROUS_DEBUG_EVENTS=false \
    TRACK_ARCHETYPE_CREATIONS_ON_STARTUP=false \
    SERVER_START_TIME_OFFSET=0.0 \
    PERSISTENCE_VERSION_OVERRIDE=-1 \
    USE_TELEPORT_PLAYERS_OUT_OF_COLLISION_FIX=true \
    REMOTE_BANS_URL="" \
    REMOTE_ADMINS_URL="" \
    AFK_KICK_TYPE=0 \
    AFK_KICK_DURATION=1 \
    AFK_KICK_WARNING_DURATION=14 \
    AFK_KICK_PLAYER_RATIO=0.5 \
    ENABLE_BACKTRACE_ANR=false \
    ANALYTICS_ENABLED=true \
    ANALYTICS_ENVIRONMENT="prod" \
    ANALYTICS_DEBUG=false \
    USE_DOUBLE_TRANSPORT_LAYER=true \
    PRIVATE_GAME=false \
    API_ENABLED=false \
    API_ADDRESS="*" \
    API_PORT=9090 \
    API_BASE_PATH="/" \
    API_ACCESS_LIST="" \
    API_PROMETHEUS_DELAY=30 \
    RCON_TIMEOUT_SECONDS=300 \
    RCON_MAX_PASSWORD_TRIES=99 \
    RCON_BAN_MINUTES=0 \
    RCON_SEND_AUTH_IMMEDIATELY=true \
    RCON_MAX_CONNECTIONS_PER_IP=20 \
    RCON_MAX_CONNECTIONS=20 \
    RCON_EXPERIMENTAL_COMMANDS_ENABLED=false \
    GAME_DIFFICULTY="Normal" \
    GAMEMODE_TYPE="PvP" \
    CLAN_SIZE=4


# Build directories
RUN mkdir ${STEAMAPPDIR} ${STEAMAPPSERVER} ${STEAMAPPDATA} ${SCRIPTSDIR}

COPY ./scripts ${SCRIPTSDIR}

RUN chown steam:steam -R ${STEAMAPPDIR} \
    && chmod +x ${SCRIPTSDIR}/*.sh \
    && mkdir /tmp/.X11-unix \
    && chmod 1777 /tmp/.X11-unix \
    && chown root /tmp/.X11-unix 

CMD ["/vrising/scripts/init.sh"]