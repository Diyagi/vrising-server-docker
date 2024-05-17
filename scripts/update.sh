#!/bin/bash
# https://github.com/thijsvanloef/palworld-server-docker/blob/main/scripts/update.sh

# shellcheck source=scripts/helper_functions.sh
source "${SCRIPTSDIR}/helper_functions.sh"

# Helper Functions for installation & updates
# shellcheck source=scripts/helper_install.sh
source "${SCRIPTSDIR}/helper_install.sh"

UpdateRequired
updateRequired=$?
# Check if Update was actually required
if [ "$updateRequired" != 0 ]; then
  exit 0
fi

if [ "${UPDATE_ON_BOOT,,}" != true ]; then
    LogWarn "An update is available however, UPDATE_ON_BOOT needs to be enabled for auto updating"
    exit 1
fi

if [ "${RCON_ENABLED,,}" != 0 ]; then
    LogWarn "An update is available however auto updating without rcon is not supported"
    exit 1
fi

if [ -z "${AUTO_UPDATE_WARN_MINUTES}" ]; then
    LogWarn "Unable to auto update, AUTO_UPDATE_WARN_MINUTES is empty."
    exit 1
fi

if [[ ! $AUTO_REBOOT_WARN_MINUTES =~ ^[0-9]+(,[0-9]+)*$ ]]; then
    LogWarn "Unable to auto update, AUTO_UPDATE_WARN_MINUTES pattern is incorrect: ${AUTO_UPDATE_WARN_MINUTES}"
    exit 1
fi

RCON "shutdown ${AUTO_UPDATE_WARN_MINUTES} \"${AUTO_UPDATE_WARN_MESSAGE}\""
