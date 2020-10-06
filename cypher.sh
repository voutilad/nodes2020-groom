#!/bin/sh
NEO4J_HOST="groom.neo4j.academy:443"

if [[ $# -eq 1 ]]; then
    docker run --rm -it --name cypher-exec \
           -v "$(pwd)/cypher:/cypher" -u root --entrypoint /bin/bash \
           neo4j:4.0-enterprise \
           -c "cypher-shell -d groom -u neo4j -a neo4j+s://${NEO4J_HOST} -f /cypher/$1"
else
    echo "cypher.sh -- usage: $0 [cypher file]" 1>&2;
    exit 1;
fi
