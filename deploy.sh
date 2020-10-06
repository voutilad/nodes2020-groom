#!/bin/sh
HOST=groom-container-host.northamerica-northeast1-a.neo4j-se-team-201905

rsync --exclude .git/ -avz ./ "${HOST}:/home/${USER}/groom"
