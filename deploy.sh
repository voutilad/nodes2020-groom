#!/bin/sh
HOST=groom-container-host.northamerica-northeast1-a.neo4j-se-team-201905
OS="$(uname -s)"

if test "${OS}" = "OpenBSD"; then
    RSYNC_CMD=openrsync
else
    RSYNC_CMD=rsync
fi

${RSYNC_CMD} -avz ./ "${HOST}:/home/${USER}"
