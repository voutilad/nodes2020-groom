# Doom + Kafka + Neo4j

This is the 3rd piece of my demo series from my presentation at Neo4's
developer conference NODES in 2020. The other pieces are:

1. [Reactive Java, UDP](https://github.com/voutilad/groom)
2. [Google Cloud, WebSockets](https://github.com/voutilad/groom-gcp)

## Using this sample project
You'll notice there's little to no code here. (The code that does
exist is some Go to help leverage Google Secrets Manager.) It's mostly
shell scripts. To recreate what I built for the live demo, you'll want
to acquire:

- a [Confluent Cloud](https://confluent.cloud) account
- a [GCP](https://cloud.google.com) account and project
- a GCE host with Docker
- a Google Cloud service account and its JSON private key

Alternatively, you *can* substitute the following:

- a local Apache Kafka deployment
- any host that can run Neo4j

You don't need Docker...I just found it easier for this use case.

> Note: it's assumed you use a Neo4j database called "groom" and not
> the default "neo4j" database. Why? I don't know...just felt like
> it I guess.

## Getting Up and Running
To recreate what I built just like in the demo:

1. Create a Confluent Cloud cluster adding a topic named `groom`
2. Generate a Confluent API Key, noting the key and the secret
   somewhere for now
3. In Google Secret Manager, make a new secret containing the
   Confluent secret value
4. Spin up a Container-Optimized OS host in GCE with at least 8GB of
   memory.
5. Copy/clone/etc. the files to the machine.
6. Create a Google Cloud Service Account in y our GCP project,
   generating a JSON private key, and granting it read access to your
   Secret you created. Deploy this key to a `./secrets` directory on
   the Neo4j host.
7. I didn't use the NEO4J_LABS plugin stuff, so fetch the latest 4.0
   compliant APOC and Neo4j-Streams plugins, putting them in
   `./plugins`
8. Run the create script, setting appropriate env vars related to your
   Confluent Cloud config and the secret you created in GSM:
   ```bash
   $ BOOTSTRAP_SERVER_URL=${CONFLUENT_URL} API_KEY=${CONFLUENT_KEY} \
     GCP_PROJECT=${YOUR_GCP_PROJECT} \
     GCP_SECRET_NAME=${YOUR_SECRET_NAME} \
     create-4.0.sh
   ```
9. Run `docker start -a neo4j-groom` and confirm Neo4j starts up and
   listens for bolt connections
10. Disconnect from the Docker connection with `ctrl-c`
11. Connect and set a Neo4j password using cypher-shell:
   ```bash
   $ docker exec -it neo4j-groom cypher-shell -u neo4j -p neo4j
   ```
12. Initialize the "groom" database via cypher-shell:
   ```
   :use system;
   CREATE DATABASE groom;
   ```
13. After disconnecting from cypher-shell, run the schema creation
    script:
    ```bash
    $ sh cypher.sh schema.cypher
    ```
14. Then schedule the threading:
    ```bash
    $ sh cypher threading.cypher
    ```

## Configuring Doom
There are details in the
[Telemetry](https://github.com/voutilad/chocolate-doom/blob/personal/TELEMETRY.md)
documentation. In general, if using Confluent Cloud, you would set the
`Topic` and `Broker` as instructed by Confluent Cloud's details for
your cluster/topic config.

For `SASL User` and `SASL Password`, use your Confluent API key and
secret respectively.

> WARNING: my Doom fork does NOT store your api secret securely. It
> stores it in plaintext in the chocolate-doom config file, which
> usually in some location of your user account. Make sure it's not
> globally readable!!!
