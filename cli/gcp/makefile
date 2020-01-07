.PHONY: build shell

pull: 
	docker pull google/cloud-sdk:latest

build: 
	docker build -t my-cloud-sdk-docker:alpine .

shell: build run

run:
	@docker run -ti \
	-e GCP_SA_FILE=${GCP_SA_FILE} \
	-e GCP_PROJECT_ID=${GCP_PROJECT_ID} \
	-e GCP_REGION=${GCP_REGION} \
	my-cloud-sdk-docker:alpine /bin/bash

test: test1 test2

test1:
	@docker run -ti  google/cloud-sdk:latest gcloud version

test2:
	@docker run --rm -ti \
	-e GCP_SA_FILE=${GCP_SA_FILE} \
	-e GCP_PROJECT_ID=${GCP_PROJECT_ID} \
	-e GCP_REGION=${GCP_REGION} \
    my-cloud-sdk-docker gcloud compute instances list --project ${GCP_PROJECT_ID}