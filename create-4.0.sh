#!/bin/sh

EVENTS_CYPHER="./cypher/events.cypher"
BOOTSTRAP_SERVER_URL="pkc-lo7py.northamerica-northeast1.gcp.confluent.cloud:9092"
API_KEY="UQJMRNNQ3PSAFO7M"
API_SECRET="$(sh fetch.sh)"
JAAS_CONFIG="org.apache.kafka.common.security.plain.PlainLoginModule required username=\"${API_KEY}\" password=\"${API_SECRET}\";"
CYPHER="$(cat ${EVENTS_CYPHER} | grep -v '//' | tr '\r\n\t' ' ')"

printf "Using Cypher:\n${CYPHER}\n"

docker create --name neo4j-groom \
	--rm -it \
	--mount="type=bind,source=$(pwd)/plugins,target=/plugins" \
	--mount="type=volume,dst=/data,volume-driver=local,volume-opt=type=ext4,volume-opt=device=/dev/sdb" \
	-e NEO4J_ACCEPT_LICENSE_AGREEMENT=yes \
	-e NEO4J_dbms_memory_heap_initial__size=8G \
	-e NEO4J_dbms_memory_heap_max__size=8G \
	-e NEO4J_dbms_memory_pagecache_size=3G \
	-e NEO4J_dbms_logs_query_enabled=INFO \
	-e NEO4J_dbms_logs_query_parameter__logging__enabled=true \
	-e NEO4J_dbms_default__advertised__address=groom.neo4j.academy \
	-e NEO4J_dbms_security_procedures_unrestricted="apoc.schema.assert" \
	-e NEO4J_kafka_retry_backoff_ms=500 \
	-e NEO4J_kafka_request_timeout_ms=20000 \
	-e NEO4J_kafka_sasl_mechanism=PLAIN \
	-e NEO4J_kafka_security_protocol=SASL_SSL \
	-e NEO4J_kafka_ssl_endpoint_identification_algorithm=https \
	-e NEO4J_kafka_sasl_jaas_config="${JAAS_CONFIG}" \
	-e NEO4J_kafka_bootstrap_servers="${BOOTSTRAP_SERVER_URL}" \
	-e NEO4J_kafka_value_deserializer=org.apache.kafka.common.serialization.ByteArrayDeserializer \
	-e NEO4J_streams_sink_topic_cypher_groom_to_groom="${CYPHER}" \
	-e NEO4J_streams_sink_enabled_to_groom=true \
	-e NEO4J_streams_source_enabled=false \
	-m 13G \
	-p 7474:7474 \
	-p 7687:7687 \
	neo4j:4.0-enterprise
