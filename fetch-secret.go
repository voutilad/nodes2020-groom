package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"strconv"

	secretmanager "cloud.google.com/go/secretmanager/apiv1"
	secretmanagerpb "google.golang.org/genproto/googleapis/cloud/secretmanager/v1"
)

const LatestVersion = -1

func accessSecretVersion(projectId, secretName string, version int) error {
	ctx := context.Background()
	client, err := secretmanager.NewClient(ctx)
	if err != nil {
		return fmt.Errorf("failed to create secretmanager client: %v", err)
	}

	name := "projects/" + projectId + "/secrets/" + secretName + "/versions/"

	if version == LatestVersion {
		name += "latest"
	} else {
		name += strconv.Itoa(version)
	}

	req := &secretmanagerpb.AccessSecretVersionRequest{
		Name: name,
	}

	result, err := client.AccessSecretVersion(ctx, req)
	if err != nil {
		return fmt.Errorf("failed to access secret version: %v", err)
	}

	fmt.Printf("%s", string(result.Payload.Data))
	return nil
}

func main() {
	project, ok := os.LookupEnv("GCP_PROJECT")
	if !ok {
		log.Fatal("Could not find GCP_PROJECT environment variable!")
	}

	secret, ok := os.LookupEnv("GCP_SECRET_NAME")
	if !ok {
		log.Fatal("Could not find GCP_SECRET_NAME environment variable!")
	}

	err := accessSecretVersion(project, secret, LatestVersion)
	if err != nil {
		log.Fatal(err)
	}
}
