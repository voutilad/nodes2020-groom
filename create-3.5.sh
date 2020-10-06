#!/bin/sh

BOOTSTRAP_SERVER_URL="pkc-lo7py.northamerica-northeast1.gcp.confluent.cloud:9092"
API_KEY="5BQYDJCXNTGJ6NGG"
API_SECRET="63qSlmfdHezHagoFgdAkvLtcbGMdjopB8c+4yzA5AsDX8QwdjNRKuAO6oJ3Vfwrk"
JAAS_CONFIG="org.apache.kafka.common.security.plain.PlainLoginModule required username=\"${API_KEY}\" password=\"${API_SECRET}\";"

docker create --name neo4j-groom \
	--rm -it \
	--mount="type=bind,source=$(pwd)/plugins,target=/plugins" \
	--mount="type=volume,dst=/data,volume-driver=local,volume-opt=type=ext4,volume-opt=device=/dev/sdb" \
	-e NEO4J_ACCEPT_LICENSE_AGREEMENT=yes \
	-e NEO4J_dbms_memory_heap_initial__size=8G \
	-e NEO4J_dbms_memory_heap_max__size=8G \
	-e NEO4J_dbms_memory_pagecache_size=3G \
	-e NEO4J_dbms_logs_query_enabled=true \
	-e NEO4J_dbms_logs_query_threshold=5s \
	-e NEO4J_dbms_logs_query_parameter__logging__enabled=false \
	-e NEO4J_dbms_default__advertised__address=groom.neo4j.academy \
	-e NEO4J_kafka_retry_backoff_ms=500 \
	-e NEO4J_kafka_request_timeout_ms=20000 \
	-e NEO4J_kafka_sasl_mechanism=PLAIN \
	-e NEO4J_kafka_security_protocol=SASL_SSL \
	-e NEO4J_kafka_ssl_endpoint_identification_algorithm=https \
	-e NEO4J_kafka_sasl_jaas_config="${JAAS_CONFIG}" \
	-e NEO4J_kafka_bootstrap_servers="${BOOTSTRAP_SERVER_URL}" \
	-e NEO4J_streams_sink_topic_cypher_groom="CREATE (:Event {id:event.id})" \
	-e NEO4J_streams_sink_enabled=true \
	-m 13G \
	-p 7474:7474 \
	-p 7687:7687 \
	neo4j:3.5-enterprise
