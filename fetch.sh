#!/bin/sh
SECRETS_DIR="./.secrets"

# for now just grab the only file
SECRET_FILE="$(ls ${SECRETS_DIR})"

if docker build -t fetch-secret:latest . > /dev/null; then
    docker run --rm -it \
           -v "$(realpath ${SECRETS_DIR}):/secrets" \
           -e GOOGLE_APPLICATION_CREDENTIALS="/secrets/${SECRET_FILE}" \
           -e GCP_PROJECT="${GCP_PROJECT}" \
           -e GCP_SECRET_NAME="${GCP_SECRET_NAME}" \
           fetch-secret:latest
fi
