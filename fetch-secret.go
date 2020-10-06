package main

import (
	secretmanager "cloud.google.com/go/secretmanager/apiv1"
	"context"
	"fmt"
	secretmanagerpb "google.golang.org/genproto/googleapis/cloud/secretmanager/v1"
	"log"
	"strconv"
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
	err := accessSecretVersion("neo4j-se-team-201905", "groom-AKMM3HDV7U35BYEO", LatestVersion)
	if err != nil {
		log.Fatal(err)
	}
}
