#!/bin/bash
# shellcheck source=scripts/helper_functions.sh
source "${SCRIPTSDIR}/helper_functions.sh"

if [[ ${RCON_ENABLED,,} != 0 ]]; then
    echo "You need RCON enabled in order to test announces."
    exit 1
fi

# This prevents the pattern from expanding to itself if no files match.
shopt -s nullglob
announceFiles=("${ANNOUNCEDIR}"/"$1"-*.announce)
shopt -u nullglob

# Check if theres actually any .announce files
if [[ ${#announceFiles[@]} -eq 0 ]]; then
    echo "No .announce files found."
    exit 1
fi

# We check if the announce file is not empty
if ! [[ -s ${announceFiles[0]} ]]; then
    echo "${announceFiles[0]} Is empty."
    exit 1
fi

fileContent=$(< "${announceFiles[0]}")

RCON "announce \"${fileContent}\""

exit $?
