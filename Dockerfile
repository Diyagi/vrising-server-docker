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
    moreutils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# set args
# SUPERCRONIC: Latest releases available at https://github.com/aptible/supercronic/releases
# RCON: Latest releases available at https://github.com/gorcon/rcon-cli/releases
ARG GORCON_VERSION="0.10.3"
ARG GORCON_MD5SUM="8601c70dcab2f90cd842c127f700e398"
ARG SUPERCRONIC_VERSION="0.2.29"    
ARG SUPERCRONIC_SHA1SUM="cd48d45c4b10f3f0bfdd3a57d054cd05ac96812b"

# Install GoRcon
RUN curl -fsSL -o rconcli.tar.gz https://github.com/gorcon/rcon-cli/releases/download/v${GORCON_VERSION}/rcon-${GORCON_VERSION}-amd64_linux.tar.gz \
    && echo "${GORCON_MD5SUM}" rconcli.tar.gz | md5sum -c - \
    && tar -xf rconcli.tar.gz --strip-components=1 --transform 's/rcon/rcon-cli/g' -C /usr/bin/ rcon-${GORCON_VERSION}-amd64_linux/rcon

# Install Supercronic
RUN curl -fsSL -o supercronic https://github.com/aptible/supercronic/releases/download/v${SUPERCRONIC_VERSION}/supercronic-linux-amd64 \
    && echo "${SUPERCRONIC_SHA1SUM}" supercronic | sha1sum -c - \
    && chmod +x supercronic \
    && mv supercronic /usr/local/bin/supercronic

ENV STEAMAPP vrising
ENV STEAMAPPDIR "/${STEAMAPP}"
ENV STEAMAPPSERVER "${STEAMAPPDIR}/server"
ENV STEAMAPPDATA "${STEAMAPPDIR}/data"
ENV LOGSDIR "${STEAMAPPDATA}/logs"
ENV SCRIPTSDIR "${STEAMAPPDIR}/scripts"
ENV ANNOUNCEDIR "${STEAMAPPDIR}/announce"

ENV PUID=1000 \
    PGID=1000 \
    UPDATE_ON_BOOT=true \
    AUTO_UPDATE_ENABLED=false \
    AUTO_UPDATE_CRON_EXPRESSION="0 * * * *" \
    AUTO_UPDATE_WARN_MINUTES="30,15,10,5,3,2,1" \
    AUTO_UPDATE_WARN_MESSAGE="Server will restart in ~{t} min. Reason: Scheduled Update" \
    AUTO_REBOOT_ENABLED=false \
    AUTO_REBOOT_CRON_EXPRESSION="0 0 * * *" \
    AUTO_REBOOT_WARN_MINUTES="15,10,5,3,2,1" \
    AUTO_REBOOT_WARN_MESSAGE="Server will restart in ~{t} min. Reason: Scheduled Restart" \
    AUTO_ANNOUNCE_ENABLED=false \
    AUTO_ANNOUNCE_CRON_EXPRESSION="*/10 * * * *" \
    AI_UPDATES_PER_FRAME= \
    GIVE_STARTER_ITEMS= \
    LOG_ALL_NETWORK_EVENTS= \
    LOG_ADMIN_EVENTS= \
    LOG_DEBUG_EVENTS= \
    ENABLE_DANGEROUS_DEBUG_EVENTS= \
    TRACK_ARCHETYPE_CREATIONS_ON_STARTUP= \
    SERVER_START_TIME_OFFSET= \
    PERSISTENCE_VERSION_OVERRIDE= \
    USE_TELEPORT_PLAYERS_OUT_OF_COLLISION_FIX= \
    ENABLE_BACKTRACE_ANR= \
    ANALYTICS_ENABLED= \
    ANALYTICS_ENVIRONMENT= \
    ANALYTICS_DEBUG= \
    API_ADDRESS= \
    API_BASE_PATH= \
    # We need this API so we limit API access for security
    API_ACCESS_LIST="127.0.0.1/32" \
    VR_API_ENABLED=true \
    GAME_DIFFICULTY= \
    GAMEMODE_TYPE= \
    CLAN_SIZE=


# Build directories
RUN mkdir ${STEAMAPPDIR} ${STEAMAPPSERVER} ${STEAMAPPDATA} ${SCRIPTSDIR} ${ANNOUNCEDIR}

COPY ./scripts ${SCRIPTSDIR}

WORKDIR ${SCRIPTSDIR}

RUN touch ${SCRIPTSDIR}/rcon.yaml \
    && chown steam:steam -R ${STEAMAPPDIR} \
    && chmod +x ${SCRIPTSDIR}/*.sh \
    && mv ${SCRIPTSDIR}/testannounce.sh /usr/local/bin/testannounce \
    && mkdir /tmp/.X11-unix \
    && chmod 1777 /tmp/.X11-unix \
    && chown root /tmp/.X11-unix

CMD ["/vrising/scripts/init.sh"]