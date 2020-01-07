https://hub.docker.com/r/google/cloud-sdk/

docker pull google/cloud-sdk:latest

docker run -ti  google/cloud-sdk:latest gcloud version

# !!WARNING this stores creds in clear text!!
docker run -ti --name gcloud-config google/cloud-sdk gcloud auth login

docker run --rm -ti --volumes-from gcloud-config google/cloud-sdk bash

gcloud compute instances list --project your_project


gcloud compute images list --project f5-7626-networks-public | grep 13-1-3-2 | grep byol