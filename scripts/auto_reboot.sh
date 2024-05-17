#!/bin/bash
# shellcheck source=scripts/helper_functions.sh
source "${SCRIPTSDIR}/helper_functions.sh"

if [ "${RCON_ENABLED}" = 1 ]; then
    LogWarn "Unable to reboot. RCON is required."
    exit 1
fi

if [ -z "${AUTO_REBOOT_WARN_MINUTESS}" ]; then
    LogWarn "Unable to auto update, AUTO_REBOOT_WARN_MINUTES is empty."
    exit 1
fi

if [[ ! $AUTO_REBOOT_WARN_MINUTES =~ ^[0-9]+(,[0-9]+)*$ ]]; then
    LogWarn "Unable to auto update, AUTO_REBOOT_WARN_MINUTES pattern is incorrect: ${AUTO_REBOOT_WARN_MINUTES}"
    exit 1
fi

RCON "shutdown ${AUTO_REBOOT_WARN_MINUTES} \"${AUTO_REBOOT_WARN_MESSAGE}\""
