#!/bin/bash
# shellcheck source=scripts/helper_functions.sh
source "${SCRIPTSDIR}/helper_functions.sh"

if [[ ${RCON_ENABLED,,} != 0 ]]; then
    LogWarn "Auto announce is enabled however auto announcing without rcon is not supported"
    exit 1
fi

# This prevents the pattern from expanding to itself if no files match.
shopt -s nullglob
announceFiles=("${ANNOUNCEDIR}"/*.announce)
shopt -u nullglob

# Check if theres actually any .announce files
if [[ ${#announceFiles[@]} -eq 0 ]]; then
    LogWarn "No .announce files found."
    exit 1
fi

# Check if lastIndex exists, if it does we load its value and add +1
# If not we start at 0
if [[ -f ${SCRIPTSDIR}/lastIndex ]]; then
    index=$(< "${SCRIPTSDIR}/lastIndex")
    ((index++))
else
    index=0
fi

# Check if current index is greater than the file list lenght
# If it is we go back to 0
# We add +1 to index bc indexes start at 0
if [[ $((index+1)) -gt ${#announceFiles[@]} ]]; then
    index=0
fi

# Save the current index into lastIndex file
echo "${index}" > "${SCRIPTSDIR}/lastIndex"

# We check if the announce file is not empty
if ! [[ -s ${announceFiles[$index]} ]]; then
    LogWarn "${announceFiles[$index]} Is empty. Skipping."
    exit 1
fi

fileContent=$(< "${announceFiles[$index]}")
RCON "announce \"${fileContent}\""

exit $?
