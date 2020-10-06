#!/bin/sh
docker run --rm -it --name cypher-exec \
	-v "$(pwd):/scripts" -u root --entrypoint /bin/bash \
	neo4j:4.0.8-enterprise \
	-c "cypher-shell -d groom -u neo4j -a bolt+s://groom.neo4j.academy:443 -f /scripts/$@"
